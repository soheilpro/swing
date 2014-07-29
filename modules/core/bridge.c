#include <stdlib.h>
#include <stdio.h>
#include "bridge.h"

/* STREAM */

typedef struct stream_context
{
    int val;
    stream_read_cb read_cb;
    stream_write_cb write_cb;
} stream_context;

void stream_alloc_cb(uv_handle_t* handle, size_t suggested_size, uv_buf_t* buf)
{
    *buf = uv_buf_init((char*)malloc(suggested_size), (unsigned int)suggested_size);
}

void stream_on_read(uv_stream_t* stream, ssize_t nread, const uv_buf_t* buf)
{
    stream_context* context = (stream_context*)stream->data;

    context->read_cb(stream, nread, buf);
}

void stream_on_write(uv_write_t* req, int status)
{
    uv_stream_t* stream = req->handle;
    stream_context* context = (stream_context*)stream->data;

    free(req);

    context->write_cb(req, status);
}

void stream_read(uv_stream_t* stream, stream_read_cb read_cb)
{
    stream_context* context = (stream_context*)stream->data;
    context->read_cb = read_cb;

    uv_read_start(stream, stream_alloc_cb, stream_on_read);
}

void stream_write(uv_stream_t* stream, const char* data, stream_write_cb write_cb)
{
    stream_context* context = (stream_context*)stream->data;
    context->write_cb = write_cb;

    uv_write_t* req = (uv_write_t*)malloc(sizeof(uv_write_t));

    size_t len = strlen(data);
    uv_buf_t buffer = uv_buf_init((char*)malloc(len), (unsigned int)len);
    buffer.base = (char*)data;
    buffer.len = len;

    uv_write(req, stream, &buffer, 1, stream_on_write);
}

void stream_close(uv_stream_t* stream)
{
    free(stream->data);
    uv_close((uv_handle_t*)stream, NULL);
}

/* TCP */

typedef struct tcp_context
{
    tcp_connection_cb connection_cb;
} tcp_context;

void tcp_on_connection(uv_stream_t* server, int status)
{
    tcp_context* context = (tcp_context*)server->data;

    if (status < 0)
    {
        context->connection_cb((uv_stream_t*)NULL, status);
        return;
    }

    uv_tcp_t* client = (uv_tcp_t*)malloc(sizeof(uv_tcp_t));
    uv_tcp_init(server->loop, client);

    int result = uv_accept(server, (uv_stream_t*)client);

    if (result < 0)
    {
        uv_close((uv_handle_t*)client, NULL);
        context->connection_cb((uv_stream_t*)NULL, status);
        return;
    }

    client->data = (stream_context*)malloc(sizeof(stream_context));
    ((stream_context*)client->data)->val = 123;

    context->connection_cb((uv_stream_t*)client, 0);
}

void tcp_create(uv_loop_t* loop, const char* ip, int port, tcp_connection_cb connection_cb)
{
    uv_tcp_t* server = (uv_tcp_t*)malloc(sizeof(uv_tcp_t));
    uv_tcp_init(loop, server);

    tcp_context* context = (tcp_context*)malloc(sizeof(tcp_context)); // TODO: Free
    context->connection_cb = connection_cb;

    server->data = context;

    struct sockaddr_in* bind_address = (struct sockaddr_in*)malloc(sizeof(struct sockaddr_in));
    uv_ip4_addr(ip, port, bind_address);

    uv_tcp_bind(server, (struct sockaddr*)bind_address, 0);

    uv_listen((uv_stream_t*)server, 128, tcp_on_connection);

    uv_run(loop, UV_RUN_DEFAULT);
}
