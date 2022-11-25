// Copyright Epic Games, Inc. All Rights Reserved.

using System;
using System.Collections.Generic;
using System.IO;
using EpicGames.Core;
using System.Text.RegularExpressions;
using Microsoft.Win32;
using System.Diagnostics;

namespace UnrealBuildTool
{
	internal partial class ApplePlatformSDK : UEBuildPlatformSDK
	{
		public override string GetMainVersion()
		{
			return "13.3";
		}

		protected override void GetValidVersionRange(out string MinVersion, out string MaxVersion)
		{
			if (RuntimePlatform.IsMac)
			{
				MinVersion = "13.4.0";
				MaxVersion = "14.9.9";
			}
			else
			{
				// @todo turnkey: these are MobileDevice .dll versions in Windows - to get the iTunes app version (12.3.4.1 etc) would need to hunt down the .exe
				MinVersion = "1100.0.0.0";
				MaxVersion = "1499.0";
			}
		}

		protected override void GetValidSoftwareVersionRange(out string? MinVersion, out string? MaxVersion)
		{
			MinVersion = MaxVersion = null;
		}

		/// <summary>
		/// The minimum Clang version that a macOS static library can be built with
		/// </summary>
		public virtual Version MinimumStaticLibClangVersion
		{
			get
			{
				// return new Version("1200.00.32.29"); // UE 5.0 (Xcode 12.4)
				// return new Version("1300.00.29.30"); // UE 5.1 (Xcode 13.2.1)
				return new Version("1400.00.28.1"); // UE 5.1 (Xcode 14.0)
			}
		}

		/// <summary>
		/// The minimum macOS SDK version that a dynamic library can be built with
		/// </summary>
		public virtual Version MinimumDynamicLibSDKVersion
		{
			get
			{
				return new Version("12.1");		// SDK used in Xcode13.2.1
			}
		}

	}
}
