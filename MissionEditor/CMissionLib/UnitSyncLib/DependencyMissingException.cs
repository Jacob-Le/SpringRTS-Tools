﻿using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

namespace CMissionLib.UnitSyncLib
{
	[Serializable]
	public class DependencyMissingException : Exception
	{
		public DependencyMissingException() {}

		public DependencyMissingException(string message) : base(message) {}

		public DependencyMissingException(string message, Exception exception) : base(message, exception) {}

		protected DependencyMissingException(SerializationInfo serializationInfo, StreamingContext streamingContext)
			: base(serializationInfo, streamingContext) {}

		public string FileName { get; set; }
		public string InternalName { get; set; }
		public List<string> MissingDependencies { get; set; }
	}
}