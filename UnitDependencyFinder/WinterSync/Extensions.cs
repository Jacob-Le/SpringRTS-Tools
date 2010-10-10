﻿using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading;

namespace MapReader
{
    public static class Extensions
    {
        public static void Pin(this Array array, Action<IntPtr> action)
        {
            var handle = GCHandle.Alloc(array, GCHandleType.Pinned);
            try {
                action(handle.AddrOfPinnedObject());
            } finally {
                handle.Free();
            }
        }

        public static unsafe GCHandle Pin(this Array array, out byte* ptr)
        {
            var handle = GCHandle.Alloc(array, GCHandleType.Pinned);
            ptr = (byte*)handle.AddrOfPinnedObject();
            return handle;
        }

        public static T Pin<T>(this Array array, Func<IntPtr, T> action)
        {
            var handle = GCHandle.Alloc(array, GCHandleType.Pinned);
            try {
                return action(handle.AddrOfPinnedObject());
            } finally {
                handle.Free();
            }
        }

        /// <summary>
        /// Initializes a struct from binary data
        /// </summary>
        public static T ToStruct<T>(this byte[] buffer)
        {
            return buffer.Pin(p => (T)Marshal.PtrToStructure(p, typeof(T)));
        }

        /// <summary>
        /// Initializes a struct from a stream (reads only the reqired bytes)
        /// </summary>
        public static T ReadStruct<T>(this Stream stream)
        {
            var buffer = new byte[Marshal.SizeOf(typeof (T))];
            stream.Read(buffer, 0, buffer.Length);
            return buffer.ToStruct<T>();
        }

        /// <summary>
        /// Initializes a struct from a binary reader (reads only the reqired bytes)
        /// </summary>
        public static T ReadStruct<T>(this BinaryReader reader)
        {
            return reader.ReadBytes(Marshal.SizeOf(typeof(T))).ToStruct<T>();
        }


        /// <summary>
        /// Reads a null-terminated string
        /// </summary>
        public static string ReadCString(this BinaryReader reader)
        {
            var chars = new List<char>();
            while (true) {
                var c = reader.ReadChar();
                if (c == '\0') return new String(chars.ToArray());
                chars.Add(c);
            }
        }


        /// <summary>
        /// Like ToDictionary except if two values have the same key, the newer value used used instead of throwing an exception
        /// </summary>
        public static Dictionary<TKey, TValue>SafeToDictionary<TSource, TKey, TValue>(this IEnumerable<TSource> source, Func<TSource, TKey> keySelector, Func<TSource, TValue> valueSelector)
        {
            var dict = new Dictionary<TKey, TValue>();
            foreach (var item in source) {
                var key = keySelector(item);
                var value = valueSelector(item);
                dict.Remove(key);
                dict[key] = value;
            }
            return dict;
        }
    }
}