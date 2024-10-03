# These patches apply fixes to Xcode, mostly need for Xcode 16
# fix logging error that shows up in Xcode debug display
curl https://github.com/loopandlearn/LoopWorkspace/commit/a016f9d73d12b62c7bb5ce00eb19c1cbd75fa12e.patch | git apply
# update provisioning profile so expiration date is recorded
curl https://github.com/loopandlearn/Loop/commit/15f73c69f8fc0f14b34989e0820007fbbfca5acf.patch | git apply --directory=Loop
# make updates to submodules that speed up initial build by about 6 minutes
curl https://github.com/dnzxy/AmplitudeService/commit/99273f5e78b2ff0563e2275c601c9fc2230327f8.patch | git apply --directory=AmplitudeService
curl https://github.com/dnzxy/AmplitudeService/commit/6f406e0100e5e4b83816d48831470a59e48d4467.patch | git apply --directory=AmplitudeService
curl https://github.com/dnzxy/LibreTransmitter/commit/5983923cfcf8cd5f0f58758ec45b9a3450d300c8.patch | git apply --directory=LibreTransmitter
curl https://github.com/dnzxy/LoopKit/commit/49df814edd30a839c0afda1ece6fe9972d40aed6.patch | git apply --directory=LoopKit
curl https://github.com/dnzxy/MixpanelService/commit/1b834dfc7e45e94f895f77125efa016fad3b540b.patch | git apply --directory=MixpanelService
curl https://github.com/dnzxy/MixpanelService/commit/6aaa1506073bc99e7329373b489bc36856b77a9b.patch | git apply --directory=MixpanelService
curl https://github.com/dnzxy/OmniBLE/commit/cafb86628d741c74fa77dfcdec1a1b5def78bde5.patch | git apply --directory=OmniBLE
curl https://github.com/dnzxy/OmniKit/commit/0232f95015f1255722c5c08ab7c32a094111ef15.patch | git apply --directory=OmniKit
