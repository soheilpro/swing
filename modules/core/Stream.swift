import Foundation

class Stream
{
    typealias ReadCallback = (data: [Byte]?, error: Error?) -> Void
    typealias WriteCallback = (error: Error?) -> Void

    let __stream: UnsafePointer<uv_stream_t>
    var __read_cb: stream_read_cb?
    var __write_cb: stream_write_cb?
    var readCallback: ReadCallback?
    var writeCallback: WriteCallback?

    init(stream: UnsafePointer<uv_stream_t>)
    {
        self.__stream = stream
        self.__read_cb = ___read_cb
        self.__write_cb = ___write_cb
    }

    func read(callback: ReadCallback)
    {
        self.readCallback = callback

        stream_read(self.__stream, __read_cb)
    }

    func write(data: [Byte], callback: WriteCallback?)
    {
        self.writeCallback = callback

        var len = UInt(data.count)
        var buffer = UnsafePointer<UInt8>(malloc(len)) // TODO: Free
        buffer.withUnsafePointer {
            p in
            memcpy(p, data, len)
        }

        stream_write(self.__stream, CString(buffer), __write_cb)
    }

    func write(data: [Byte])
    {
        self.write(data, callback: nil)
    }

    func close()
    {
        stream_close(self.__stream)
    }

    func ___read_cb(stream: UnsafePointer<uv_stream_t>, nread: ssize_t, buf: ConstUnsafePointer<uv_buf_t>)
    {
        if (nread < 0)
        {
            self.close();

            if (nread != -4095) // UV_EOF
            {
                self.readCallback?(data: nil, error: Error())
            }

            return;
        }

        var data: [Byte] = Array(count: nread, repeatedValue: 0)
        memcpy(&data, buf.memory.base, UInt(nread))

        self.readCallback?(data: data, error: nil)
    }

    func ___write_cb(req: UnsafePointer<uv_write_t>, status: CInt)
    {
        self.writeCallback?(error: nil);
    }
}