-----------------------------------------------------------------------------------------------------
-- @name         log_ext
-- @author       地窖上的松
-- @License      by-nc-sa 4.0
-- @version      1.5
-----------------------------------------------------------------------------------------------------
-----------------------------------------参数定义部分-------------------------------------------------
port = 14430             -- http端口
----------------------------------------自定义回执部分------------------------------------------------
upload_file_success = "" -- 文件上传成功时的回复，默认为空，可用参数log_name

upload_file_fail = "日志文件发送失败x：{err}"

no_para = "请写出要操作的日志名x" -- 指令后没有参数时的回复

log_no_exist = "日志不存在x"
-----------------------------------------------------------------------------------------------------

msg_order = {}
msg_order[".log get"] = "log_get"

global_path = getDiceDir() .. "\\user\\log\\"
json = require("json")
group_log_pref = {
    "g",
    "",
    "group_",
}

function send_private_log(msg, log_name_raw)
    local para = {}
    pref = "usr" .. msg.uid
    end_point = "/upload_private_file"
    log_name = pref .. "_" .. log_name_raw .. ".txt"
    msg.log_name = log_name_raw

    para["user_id"] = msg.uid
    para["file"] = global_path .. log_name
    para["name"] = log_name
    local stat, data = http.post("http://127.0.0.1:" .. port .. end_point,
        json.encode(para))
    if stat then
        data = json.decode(data)
        if data.status == "ok" then -- 成功即发送文件
            return upload_file_success
        else
            msg.err = data.message
            return upload_file_fail
        end
    else
        return
        "API调用失败！请确保已经开启ob11的http连接！\n详情请看原帖:https://forum.kokona.tech/d/1994-zhi-ling-jiao-ben-e-wai-de-ri-zhi-cao-zuo-zhi-ling-log-listgetdel"
    end
end

function send_group_log(msg, log_name_raw)
    local para = {}
    end_point = "/upload_group_file"

    para["group_id"] = msg.gid

    for k, v in ipairs(group_log_pref) do
        para["name"] = v .. msg.gid .. "_" .. log_name_raw .. ".txt"
        log_path = global_path .. para["name"]
        para["file"] = log_path

        local stat, data = http.post("http://127.0.0.1:" .. port .. end_point,
            json.encode(para))
        if stat then
            data = json.decode(data)
            if data.status == "ok" then -- 成功即发送文件
                return upload_file_success
            else
                if string.match(data.message, "TypeError: Cannot read properties of undefined %(reading 'toString'%)") or string.match(data.message, "no such file or directory") then
                    msg.err = log_no_exist
                    goto continue
                else
                    msg.err = data.message
                end
                return upload_file_fail
            end
        else
            return
            "API调用失败！请确保已经开启ob11的http连接！\n详情请看原帖:https://forum.kokona.tech/d/1994-zhi-ling-jiao-ben-e-wai-de-ri-zhi-cao-zuo-zhi-ling-log-listgetdel"
        end
        ::continue::
    end
    return upload_file_fail
end

function log_get(msg)
    local name = string.match(msg.suffix, "^[%s]*(.-)[%s]*$")
    if name == "" then return no_para end

    if msg.gid then
        return send_group_log(msg, name)
    else
        return send_private_log(msg, name)
    end
end
