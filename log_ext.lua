-----------------------------------------------------------------------------------------------------
-- @name         log_ext
-- @author       地窖上的松
-- @License      by-nc-sa 4.0
-- @version      1.5
-----------------------------------------------------------------------------------------------------
----------------------------------------自定义回执部分------------------------------------------------
group_log_list_msg =
"本群log列表为：{log_list}\n若log名为时间戳，则括号内的数字为真正的log名，使用log get指令时请使用括号内数字。"

user_log_list_msg =
"小窗log列表为：{log_list}\n若log名为时间戳，则括号内的数字为真正的log名，使用log get指令时请使用括号内数字。"

have_no_logs = "此窗口没有log记录x"

delete_file_success = "成功删除日志：{log_name}"

delete_file_fail = "删除日志失败：{err}"

no_para = "请写出要操作的日志名x" -- 指令后没有参数时的回复

logging_true = "本群log状态: 日志记录中\n日志名: {logging_name}\n日志文件: {logging_file}\n日志开始时间: {logging_start_time}"

logging_false = "本群log状态: 未开始记录日志\n上一个日志文件: {logging_name}"
-----------------------------------------------------------------------------------------------------

msg_order = {}
msg_order[".log list"] = "log_list"
msg_order[".log del"] = "log_del"
msg_order[".log stat"] = "log_stat"
-- msg_order[".log http init"] = "http_init"

global_path = getDiceDir() .. "\\user\\log\\"
group_conf_path = getDiceDir() .. "\\user\\session\\"
json = require("json")

function log_list(msg)
    local pref = ""
    local log_name = ""
    local files_list = getFileList(global_path)
    -- local logs_table = {}
    local log_msg = ""
    local log_number = 0

    if msg.gid then
        pref = msg.gid
    else
        pref = "usr" .. msg.uid
    end

    if files_list then
        for key, log_file in ipairs(files_list) do
            log_name = string.match(log_file, pref .. "_(.*).txt")
            if log_name then
                if tonumber(log_name) then      -- 如果日志名为时间戳，即创建日志时未定义日志名
                    if tonumber(log_name) > 1296520386 and 2096520386 >
                        tonumber(log_name) then -- 排除掉那些以数字为log名的
                        log_name = os.date(
                                "%Y年%m月%d日 %H时%M分%S秒创建的日志",
                                tonumber(log_name)) .. "(" .. log_name ..
                            ")"
                    end
                end

                log_msg = log_msg .. "\n" .. log_name
                log_number = log_number + 1

                if log_number % 10 == 0 then
                    log_msg = log_msg .. "\f" -- 防止文本太长
                end

                -- table.insert(logs_table,log_name)
            end
        end
        if log_number ~= 0 then
            if msg.gid then
                -- 实现自定义回执
                msg.log_list = log_msg
                log_msg = group_log_list_msg
            else
                msg.log_list = log_msg
                log_msg = user_log_list_msg
            end
            return log_msg
        else
            return have_no_logs
        end
    end
end

function log_del(msg)
    local name = string.match(msg.suffix, "^[%s]*(.-)[%s]*$")
    if name == "" then return no_para end
    local pref = ""
    if msg.gid then
        pref = "g" .. msg.gid
    else
        pref = "usr" .. msg.uid
    end
    msg.log_name = name
    local log_name = pref .. "_" .. name .. ".txt"
    local err = delete_file(global_path .. log_name)
    if not err then
        return delete_file_success
    else
        if string.match(err, "No such file or directory") then
            msg.err = "文件不存在"
        else
            msg.err = err
        end
        return delete_file_fail
    end
end

function log_stat(msg)
    local files_list = getFileList(group_conf_path) -- 懒得写检测文件是否存在了，干脆直接遍历

    if msg.gid then
        pref = msg.gid
    else
        pref = "usr" .. msg.uid
    end

    if files_list then
        for key, file in ipairs(files_list) do
            conf_name = string.match(file, pref .. ".json")
            if conf_name then
                group_conf = read_json(group_conf_path .. file)
                log_conf = group_conf["log"]
                log_stat = log_conf.logging
                if log_stat then
                    msg.logging_name = log_conf.name
                    msg.logging_start_time = os.date(
                        "%Y年%m月%d日 %H时%M分%S秒",
                        tonumber(log_conf.start))
                    msg.logging_file = log_conf.file
                    return logging_true
                else
                    msg.logging_name = log_conf.name
                    return logging_false
                end
            end
        end
    end
end

-----------------------------------------------------------------------------------------------------
-------------------------------------------函数部分---------------------------------------------------
-----------------------------------------------------------------------------------------------------
function delete_file(path)            -- 删除文件,删除成功返回nil
    local file = io.open(path, "r")
    if file then file:close(path) end -- 先关闭再删除
    -- 删除失败os.remove会返回nil与错误信息
    local stat, err = os.remove(path)
    return err
end

function getFileList(path) -- 读取文件夹列表，
    local a = io.popen("dir " .. path .. "/b")
    local fileTable = {}

    if a == nil then
        return nil
    else
        for l in a:lines() do table.insert(fileTable, l) end
    end
    return fileTable
end

function write_file(path, text, mode) -- 将text以mode模式写入path对应的路径文件中
    file = io.open(path, mode)
    file.write(file, text)
    io.close(file)
end

function getGocqDir()
    local s, e = string.find(getDiceDir(), "Dice" .. getDiceQQ())
    return string.sub(getDiceDir(), 0, s - 1)
end

GocqPath = getGocqDir()

function http_init()
    if getUserConf(msg.uid, "trust", 0) < 5 then return "{strNotAdmin}" end

    -- 检测15700端口是否已有占用程序
    local port = 15700
    local stat, data = http.get("http://127.0.0.1:" .. port)
    if stat or data ~= "无法与服务器建立连接" then
        while true do
            -- 找到一个未被占用的端口
            port = ranint(10000, 65535)
            stat, data = http.get("http://127.0.0.1:" .. port)
            if stat or data ~= "无法与服务器建立连接" then
            else
                break
            end
        end
    end
    -- 写入配置
    local http_text = "\n  " .. [[- http:
      address: 127.0.0.1:]] .. port .. "\n      " .. [[timeout: 5
      long-polling:
        enabled: false
        max-queue-size: 2000
      middlewares:
        <<: *default]]
    write_file(GocqPath .. "config.yml", http_text, "a")
    return "http配置写入完成，使用端口" .. port ..
        "，请手动重启gocq以启用"
end

function read_json(path)                            --读json
    local json_t = nil
    local file = io.open(path, "r")                 --打开外置json
    if file ~= nil then
        json_t = json.decode(file.read(file, "*a")) --将json中的数组解码为table
        io.close(file)                              --关闭json
    end
    return json_t
end
