// Copyright Epic Games, Inc. All Rights Reserved.

using System;

namespace EpicGames.Core
{
	/// <summary>
	/// Attribute to indicate the name of a command line argument
	/// </summary>
	[AttributeUsage(AttributeTargets.Field | AttributeTargets.Property, AllowMultiple = true)]
	public class CommandLineAttribute : Attribute
	{
		/// <summary>
		/// Prefix for the option, with a leading '-' and trailing '=' character if a value is expected.
		/// </summary>
		public string? Prefix { get; set; }

		/// <summary>
		/// Specifies a fixed value for this argument. Specifying an alternate value is not permitted.
		/// </summary>
		public string? Value { get; set; } = null;

		/// <summary>
		/// Whether this argument is required
		/// </summary>
		public bool Required { get; set; }

		/// <summary>
		/// For collection types, specifies the separator character between multiple arguments
		/// </summary>
		public char ListSeparator { get; set; } = '\0';

		/// <summary>
		/// Description of the operation.
		/// </summary>
		public string? Description { get; set; }

		/// <summary>
		/// Constructor
		/// </summary>
		/// <param name="prefix">Prefix for this argument</param>
		public CommandLineAttribute(string? prefix = null)
		{
			Prefix = prefix;

			if(prefix != null)
			{
				if(!prefix.StartsWith("-"))
				{
					throw new Exception("Command-line arguments must begin with a '-' character");
				}
			}
		}
	}
}
