#!/usr/bin/env python3
"""Reject iOS releases that cannot launch with the iOS 27 UIScene lifecycle."""

import plistlib
import sys
from pathlib import Path


def verify(path: Path) -> None:
    with path.open("rb") as source:
        info = plistlib.load(source)
    scenes = (
        info.get("UIApplicationSceneManifest", {})
        .get("UISceneConfigurations", {})
        .get("UIWindowSceneSessionRoleApplication", [])
    )
    if not scenes:
        raise ValueError("missing application scene configuration required by the iOS 27 SDK")
    for scene in scenes:
        if scene.get("UISceneDelegateClassName") != "FlutterSceneDelegate":
            raise ValueError("application scene must use FlutterSceneDelegate")
        if scene.get("UISceneClassName") != "UIWindowScene":
            raise ValueError("application scene must use UIWindowScene")
        if scene.get("UISceneStoryboardFile") != "Main":
            raise ValueError("application scene must load the Main storyboard")
    if path.parent.suffix == ".app":
        if not any(path.parent.rglob("Main.storyboardc")):
            raise ValueError("compiled Main storyboard is missing from app bundle")


if __name__ == "__main__":
    try:
        verify(Path(sys.argv[1]))
    except (IndexError, OSError, ValueError, plistlib.InvalidFileException) as error:
        print(f"iOS scene verification failed: {error}", file=sys.stderr)
        sys.exit(1)
    print("iOS scene configuration verified")
