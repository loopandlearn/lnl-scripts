# These patches apply fixes to Xcode, mostly need for Xcode 16
echo "Some Xcode issues are patched with the next few commands."
echo "  Code will build fine with Xcode 15.4 as well as 16.x."
echo ""
echo "  If a PR patch gives an error - the PR was probably merged and script not yet updated."
echo "   You can ignore the error."
echo ""
# fix logging error that shows up in Xcode debug display
echo "1. Apply a patch taken from LoopWorkspace PR 183"
echo "   - fixes a reported error in Xcode debug log"
echo ""
curl https://github.com/loopandlearn/LoopWorkspace/commit/a016f9d73d12b62c7bb5ce00eb19c1cbd75fa12e.patch | git apply
echo ""
# update provisioning profile so expiration date is recorded
# Note that PR 2226 also modifies the version number, but this patch only fixes expiration date
echo "2. Apply a patch similar to Loop PR 2226"
echo "   - Xcode 16 fix for reporting expiration date"
echo ""
curl https://github.com/loopandlearn/Loop/commit/15f73c69f8fc0f14b34989e0820007fbbfca5acf.patch | git apply --directory=Loop
echo ""
# make updates to submodules that speed up initial build by about 6 minutes
echo "3. Make modifications that speed up building with Xcode 16"
find . -name "*.pbxproj" -exec sed -i '' 's/ENABLE_MODULE_VERIFIER = YES;/ENABLE_MODULE_VERIFIER = "$(CLANG_MODULES_ENABLE_VERIFIER_TOOL)";/g' {} +
echo ""
echo "Done with patches"
