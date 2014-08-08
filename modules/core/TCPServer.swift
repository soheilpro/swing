import Foundation

public class TCPServer
{
    public typealias NewConnectionCallback = (client: Stream?, error: Error?) -> Void

    var ip: String
    var port: Int
    var newConnectionCallback: NewConnectionCallback?
    var clients: [Stream]

    public init(ip: String, port: Int)
    {
        self.ip = ip;
        self.port = port;
        self.clients = [Stream]()
    }

    public func start(newConnectionCallback: NewConnectionCallback)
    {
        self.newConnectionCallback = newConnectionCallback

        tcp_create(Loop.DefaultLoop.__uv_loop, (self.ip as NSString).UTF8String, CInt(self.port), __connection_cb);
    }

    func __connection_cb(client: UnsafeMutablePointer<uv_stream_t>, status: CInt) -> Void
    {
        if (status < 0)
        {
            self.newConnectionCallback?(client: nil, error: Error());
            return;
        }

        let client = Stream(stream: client)
        self.clients.append(client)

        self.newConnectionCallback?(client: client, error: nil);
    }
}
