httpplus = require("httpplus")

function upload()
    local req_params = {
        url = "https://lms.caihuijingchun.cn/api/upload",
        method = "POST",
        headers = {
            ["user"] = "lms",
        },
        files = {
            ["file"] = RECORD_FILE,
        },
        server_cert = SERVER_CERT,
        client_cert = CLIENT_CERT,
        client_key = CLIENT_KEY,
    }

    code, response = httpplus.request(req_params)
    log.info("network", "upload", code, response)
    return (code == 200)
end
