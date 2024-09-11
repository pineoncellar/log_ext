-----------------------------------------------------------------------------------------------------
-- @name         log_ext
-- @author       �ؽ��ϵ���
-- @License      by-nc-sa 4.0
-- @version      1.5
-----------------------------------------------------------------------------------------------------
----------------------------------------�Զ����ִ����------------------------------------------------
group_log_list_msg =
"��Ⱥlog�б�Ϊ��{log_list}\n��log��Ϊʱ������������ڵ�����Ϊ������log����ʹ��log getָ��ʱ��ʹ�����������֡�"

user_log_list_msg =
"С��log�б�Ϊ��{log_list}\n��log��Ϊʱ������������ڵ�����Ϊ������log����ʹ��log getָ��ʱ��ʹ�����������֡�"

have_no_logs = "�˴���û��log��¼x"

delete_file_success = "�ɹ�ɾ����־��{log_name}"

delete_file_fail = "ɾ����־ʧ�ܣ�{err}"

no_para = "��д��Ҫ��������־��x" -- ָ���û�в���ʱ�Ļظ�

logging_true = "��Ⱥlog״̬: ��־��¼��\n��־��: {logging_name}\n��־�ļ�: {logging_file}\n��־��ʼʱ��: {logging_start_time}"

logging_false = "��Ⱥlog״̬: δ��ʼ��¼��־\n��һ����־�ļ�: {logging_name}"
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
                if tonumber(log_name) then      -- �����־��Ϊʱ�������������־ʱδ������־��
                    if tonumber(log_name) > 1296520386 and 2096520386 >
                        tonumber(log_name) then -- �ų�����Щ������Ϊlog����
                        log_name = os.date(
                                "%Y��%m��%d�� %Hʱ%M��%S�봴������־",
                                tonumber(log_name)) .. "(" .. log_name ..
                            ")"
                    end
                end

                log_msg = log_msg .. "\n" .. log_name
                log_number = log_number + 1

                if log_number % 10 == 0 then
                    log_msg = log_msg .. "\f" -- ��ֹ�ı�̫��
                end

                -- table.insert(logs_table,log_name)
            end
        end
        if log_number ~= 0 then
            if msg.gid then
                -- ʵ���Զ����ִ
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
            msg.err = "�ļ�������"
        else
            msg.err = err
        end
        return delete_file_fail
    end
end

function log_stat(msg)
    local files_list = getFileList(group_conf_path) -- ����д����ļ��Ƿ�����ˣ��ɴ�ֱ�ӱ���

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
                        "%Y��%m��%d�� %Hʱ%M��%S��",
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
-------------------------------------------��������---------------------------------------------------
-----------------------------------------------------------------------------------------------------
function delete_file(path)            -- ɾ���ļ�,ɾ���ɹ�����nil
    local file = io.open(path, "r")
    if file then file:close(path) end -- �ȹر���ɾ��
    -- ɾ��ʧ��os.remove�᷵��nil�������Ϣ
    local stat, err = os.remove(path)
    return err
end

function getFileList(path) -- ��ȡ�ļ����б�
    local a = io.popen("dir " .. path .. "/b")
    local fileTable = {}

    if a == nil then
        return nil
    else
        for l in a:lines() do table.insert(fileTable, l) end
    end
    return fileTable
end

function write_file(path, text, mode) -- ��text��modeģʽд��path��Ӧ��·���ļ���
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

    -- ���15700�˿��Ƿ�����ռ�ó���
    local port = 15700
    local stat, data = http.get("http://127.0.0.1:" .. port)
    if stat or data ~= "�޷����������������" then
        while true do
            -- �ҵ�һ��δ��ռ�õĶ˿�
            port = ranint(10000, 65535)
            stat, data = http.get("http://127.0.0.1:" .. port)
            if stat or data ~= "�޷����������������" then
            else
                break
            end
        end
    end
    -- д������
    local http_text = "\n  " .. [[- http:
      address: 127.0.0.1:]] .. port .. "\n      " .. [[timeout: 5
      long-polling:
        enabled: false
        max-queue-size: 2000
      middlewares:
        <<: *default]]
    write_file(GocqPath .. "config.yml", http_text, "a")
    return "http����д����ɣ�ʹ�ö˿�" .. port ..
        "�����ֶ�����gocq������"
end

function read_json(path)                            --��json
    local json_t = nil
    local file = io.open(path, "r")                 --������json
    if file ~= nil then
        json_t = json.decode(file.read(file, "*a")) --��json�е��������Ϊtable
        io.close(file)                              --�ر�json
    end
    return json_t
end
