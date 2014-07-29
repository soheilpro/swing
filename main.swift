import Foundation
import core

let server = TCPServer(ip: "127.0.0.1", port: 8080)

println("Waiting for connection...")

server.start {(client, error) in

    println("New connection")

    let data = [Byte("H"), Byte("I"), 13, 10]

    client?.write(data);

    client?.read {(data, error) in

        println("Incoming data: \(data)")

        client?.write(data!);
    }
}
