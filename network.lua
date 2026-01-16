local CERT_FILE = "/luadb/voicer.crt"
local KEY_FILE = "/luadb/voicer.key"

function network_task()
	while true do
		sys.waitMsg("network_task", "upload")
		upload()
	end
end

function upload()
	log.info("network", "uploading")
	local req = {
		url = "https://lms.caihuijingchun.cn/api/upload",
		method = "POST",
		headers = {
			["user"] = "lms"
		},
		files = {
			["file"] = "/record.amr"
		}
	}
	local code, response = httpplus.request(req)
	while code ~= 200 do
		log.info("network", "retrying", code, response)
		sys.wait(30000)
		local code, response = httpplus.request(req)
	end
	log.info("network", "uploaded successfully")
end

return {
	network_task = network_task
}