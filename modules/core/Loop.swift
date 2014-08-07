let __defaultLoop = Loop(uv_loop: uv_default_loop())

class Loop
{
    class var DefaultLoop : Loop
    {
        return __defaultLoop
    }

    var __uv_loop: UnsafeMutablePointer<uv_loop_t>

    init(uv_loop: UnsafeMutablePointer<uv_loop_t>)
    {
        self.__uv_loop = uv_loop;
    }
}
