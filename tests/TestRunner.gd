class_name TestRunner
extends RefCounted

## Shared headless test formatter for all SEProject test suites.
## Produces clean, consistent, cross-platform ASCII output on Linux, macOS, Windows, and CI.

var suite_name: String = ""
var passed: int = 0
var failed: int = 0

func _init(name: String) -> void:
	suite_name = name
	print("============================================================")
	print("[TEST] %s" % suite_name)
	print("============================================================")

func section(title: String) -> void:
	print("[%s]" % title)

func check(condition: bool, message: String) -> bool:
	if condition:
		passed += 1
		print("  [PASS] %s" % message)
	else:
		failed += 1
		print("  [FAIL] %s" % message)
	return condition

func finish(tree: SceneTree) -> void:
	var total: int = passed + failed
	var status: String = "PASS" if failed == 0 else "FAIL"
	print("------------------------------------------------------------")
	print("[SUMMARY] %s: %d/%d passed, %d failed -> %s" % [suite_name, passed, total, failed, status])
	print("============================================================")
	tree.quit(0 if failed == 0 else 1)
