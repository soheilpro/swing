import Foundation

public class Stream
{
    public typealias ReadCallback = (data: [Byte]?, error: Error?) -> Void
    public typealias WriteCallback = (error: Error?) -> Void

    let __stream: UnsafeMutablePointer<uv_stream_t>
    var __read_cb: stream_read_cb?
    var __write_cb: stream_write_cb?
    var readCallback: ReadCallback?
    var writeCallback: WriteCallback?

    public init(stream: UnsafeMutablePointer<uv_stream_t>)
    {
        self.__stream = stream
        self.__read_cb = ___read_cb
        self.__write_cb = ___write_cb
    }

    public func read(callback: ReadCallback)
    {
        self.readCallback = callback

        stream_read(self.__stream, __read_cb)
    }

    public func write(data: [Byte], callback: WriteCallback?)
    {
        self.writeCallback = callback

        var len = UInt(data.count)
        var buffer = UnsafeMutablePointer<Int8>(malloc(len)) // TODO: Free
        memcpy(buffer, data, len)

        stream_write(self.__stream, buffer, __write_cb)
    }

    public func write(data: [Byte])
    {
        self.write(data, callback: nil)
    }

    public func close()
    {
        stream_close(self.__stream)
    }

    func ___read_cb(stream: UnsafeMutablePointer<uv_stream_t>, nread: ssize_t, buf: UnsafePointer<uv_buf_t>)
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

    func ___write_cb(req: UnsafeMutablePointer<uv_write_t>, status: CInt)
    {
        self.writeCallback?(error: nil);
    }
}