import Foundation

class TCPServer
{
    typealias NewConnectionCallback = (client: Stream?, error: Error?) -> Void

    var ip: String
    var port: Int
    var newConnectionCallback: NewConnectionCallback?
    var clients: [Stream]

    init(ip: String, port: Int)
    {
        self.ip = ip;
        self.port = port;
        self.clients = [Stream]()
    }

    func start(newConnectionCallback: NewConnectionCallback)
    {
        self.newConnectionCallback = newConnectionCallback

        tcp_create(Loop.DefaultLoop.__uv_loop, self.ip.bridgeToObjectiveC().UTF8String, CInt(self.port), __connection_cb);
    }

    func __connection_cb(client: UnsafePointer<uv_stream_t>, status: CInt) -> Void
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
