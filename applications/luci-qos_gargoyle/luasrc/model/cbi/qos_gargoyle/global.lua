
local wa = require "luci.tools.webadmin"
local fs = require "nixio.fs"

m = Map("qos_gargoyle",translate("Qos_Switch"),translate("Qos_Switch is designed for switching  on/off Qos_Gargoyle."))

s = m:section(NamedSection, "config", "qos_gargoyle", "")

e = s:option(Flag, "enabled", translate("Enable"))
e.rmempty = false
e.default = e.enabled

function e.write(self, section, value)
	if value == "0" then
		os.execute("/etc/init.d/qos_gargoyle stop")
		os.execute("/etc/init.d/qos_gargoyle disable")
		os.execute("/etc/init.d/qos-relay disable")
	else
		os.execute("/etc/init.d/qos_gargoyle enable")
		os.execute("/usr/bin/qos_gargoyle restart &")
		os.execute("/etc/init.d/qos-relay enable")
	end
	Flag.write(self, section, value)
end

s = m:section(TypedSection, "global", translate("Global"), translate("<b><font color=\"#FF0000\" size=\"4\"></font></b>"))

s.anonymous = false
--s.sortable  = true
local count = 0
for line in io.lines("/etc/config/qos_gargoyle") do
	line = string.match(line, "config ['\"]*global['\"]* ")
	if line ~= nil then
		count = count + 1
	end
end
if count == 0 then
	os.execute("echo \"\nconfig global 'global'\" >> /etc/config/qos_gargoyle")
end


mtu = s:option(Value, "mtu", translate("mtu"))
mtu.datatype = "and(uinteger,min(1))"

network = s:option(Value, "network", translate("network"),translate("wan,lan....."))
network.default = ""
wa.cbi_add_networks(network)

interface=s:option(Value, "interface", translate("interface"),translate("eth0,eth1,wlan0....."))
interface.anonymous = true
interface.rmempty = true
interface.default = ""
for k, v in pairs(luci.sys.net.devices()) do
	interface:value(v)
end


s = m:section(TypedSection, "upload", translate("UpLoad"))

monenabled = s:option(ListValue, "monenabled", translate("enable upload qos"))
monenabled:value("false")
monenabled:value("true")
monenabled.default = "false"

uclass = s:option(Value, "default_class", translate("default_class"))
uclass.rmempty = "true"
for line in io.lines("/etc/config/qos_gargoyle") do
	local str = line
	line = string.gsub(line, "config ['\"]*upload_class['\"]* ", "")
	if str ~= line then
		line = string.gsub(line, "^'", "")
		line = string.gsub(line, "^\"", "")
		line = string.gsub(line, "'$", "")
		line = string.gsub(line, "\"$", "")
		uclass:value(line, translate(m.uci:get("qos_gargoyle", line, "name")))
	end
end

tb = s:option(Value, "total_bandwidth", translate("total_bandwidth"), translate("kbit/s"))
tb.datatype = "and(uinteger,min(1))"


s = m:section(TypedSection, "download", translate("DownLoad"))

monenabled = s:option(ListValue, "monenabled", translate("enable download qos"))
monenabled:value("false")
monenabled:value("true")
monenabled.default = "false"

dclass = s:option(Value, "default_class", translate("default_class"))
dclass.rmempty = "true"
for l in io.lines("/etc/config/qos_gargoyle") do
	local s = l
	l = string.gsub(l, "config ['\"]*download_class['\"]* ", "")
	if s ~= l then
		l = string.gsub(l, "^'", "")
		l = string.gsub(l, "^\"", "")
		l = string.gsub(l, "'$", "")
		l = string.gsub(l, "\"$", "")
		dclass:value(l, translate(m.uci:get("qos_gargoyle", l, "name")))
	end
end

tb = s:option(Value, "total_bandwidth", translate("total_bandwidth"), translate("kbit/s"))
tb.datatype = "and(uinteger,min(1))"

return m
