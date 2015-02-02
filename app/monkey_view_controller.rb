include OpenGLHelper

class MonkeyViewController < GLKViewController

  def loadView
    self.view = GLKView.alloc.initWithFrame(UIScreen.mainScreen.bounds)
  end

  def setupGL
    EAGLContext.setCurrentContext(@context)
  end

  def tearDownGL
    EAGLContext.setCurrentContext(@context)
  end

  def viewDidLoad
    super
    @context = EAGLContext.alloc.initWithAPI(KEAGLRenderingAPIOpenGLES2)
    if (!@context)
      puts "Failed to create ES context"
    end
    self.view.context = @context
    setupGL
    surfaceCreated
  end

  def viewDidUnload
    super
    tearDownGL
    if (EAGLContext.currentContext == @context)
      EAGLContext.setCurrentContext(nil)
    end
    @context = nil
  end

  def viewDidLayoutSubviews
    UIScreen.mainScreen.bounds.tap do |bounds|
      surfaceChanged bounds.size.width, bounds.size.height
    end
  end

  def surfaceCreated
    glClearColor(0, 0, 0, 1)

    @mesh = WavefrontMesh.new pathForResource('monkey.obj')
    @shader = Shader.new pathForResource('vertex.glsl'), pathForResource('fragment.glsl')

    @mesh.load
    @shader.load.use

    colorHandle = glGetUniformLocation(@shader.handle, "vColor")
    glUniform4fv(colorHandle, 1, to_ptr(:float, [1.0, 0.0, 1.0, 1.0]))

    @worldHandle = glGetUniformLocation(@shader.handle, "world")
    @projHandle = glGetUniformLocation(@shader.handle, "projection")
    @viewHandle = glGetUniformLocation(@shader.handle, "view")

    @viewAngle = 0.0
  end

  def surfaceChanged width, height
    glViewport(0, 0, width, height)

    ratio = width.to_f / height.to_f

    projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0), ratio, 0.1, 100.0)
    glUniformMatrix4fv(@projHandle, 1, GL_FALSE, matrix_ptr(projectionMatrix))
  end

  def glkView(view, drawInRect:rect)
    glEnable(GL_DEPTH_TEST)
    glEnable(GL_CULL_FACE)
    glCullFace(GL_BACK)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    glUniformMatrix4fv(@viewHandle, 1, GL_FALSE, matrix_ptr(viewMatrix))

    worldMatrix = GLKMatrix4Identity
    glUniformMatrix4fv(@worldHandle, 1, GL_FALSE, matrix_ptr(worldMatrix))

    @mesh.draw(@shader)
  end

  def update
    @viewAngle += 2.0
  end

  def didReceiveMemoryWarning
    super
  end

  private
  def viewMatrix
    x = 5.0 * Math::cos(GLKMathDegreesToRadians @viewAngle)
    y = 5.0 * Math::sin(GLKMathDegreesToRadians @viewAngle)
    GLKMatrix4MakeLookAt(
      x, 0.0, y,
      0.0, 0.0, 0.0,
      0.0, 1.0, 0.0
    )
  end

  def pathForResource file
    ext = File.extname file
    name = File.basename file, ext

    NSBundle.mainBundle.pathForResource(name, ofType: ext)
  end
end
