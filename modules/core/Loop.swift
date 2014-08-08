let __defaultLoop = Loop(uv_loop: uv_default_loop())

public class Loop
{
    public class var DefaultLoop : Loop
    {
        return __defaultLoop
    }

    var __uv_loop: UnsafeMutablePointer<uv_loop_t>

    public init(uv_loop: UnsafeMutablePointer<uv_loop_t>)
    {
        self.__uv_loop = uv_loop;
    }
}
