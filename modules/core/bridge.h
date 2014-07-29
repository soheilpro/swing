#include <libuv/uv.h>

typedef void (^stream_read_cb)(uv_stream_t* stream, ssize_t nread, const uv_buf_t* buf);
typedef void (^stream_write_cb)(uv_write_t* req, int status);
typedef void (^tcp_connection_cb)(uv_stream_t* stream, int status);

void stream_read(uv_stream_t* stream, stream_read_cb read_cb);
void stream_write(uv_stream_t* stream, const char* data, stream_write_cb write_cb);
void stream_close(uv_stream_t* stream);
void tcp_create(uv_loop_t* loop, const char* ip, int port, tcp_connection_cb connection_cb);