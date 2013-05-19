/**
 * This code is to cultivate a better understanding "MapReduce".
 * Reference:
 * 「GoogleのMapReduceアルゴリズムをJavaで理解する」
 * http://www.atmarkit.co.jp/fjava/special/distributed01/distributed01_1.html
 **/
 
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Algorithm {
	
	struct MapEntry : IComparable<MapEntry>, IComparable
	{
		public char Key
		{
			get;
			private set;
		}
		
		public int Value
		{
			get;
			private set;
		}
		
		internal MapEntry(char entryKey, int entryValue)
			: this()
		{
			Key = entryKey;
			Value = entryValue;
		}
		
		public int CompareTo(MapEntry other)
		{
			return other.Key - Key;
		}
		
		int IComparable.CompareTo(object obj)
		{
			if (obj is MapEntry)
			{
				MapEntry other = (MapEntry)obj;
				return CompareTo(other);
			}
			else
			{
				throw new ArgumentException("Compare target is not MapEntry.");
			}
		}
		
		public override bool Equals(object o)
		{
			if (o is MapEntry)
			{
				MapEntry entry = (MapEntry)o;
				return entry.Key.Equals(Key);
			}
			else
			{
				return false;
			}
		}
		
		public bool Equals(MapEntry entry)
		{
			return entry.Key.Equals(Key);
		}
		
		public override int GetHashCode()
		{
			return Key;
		}		
		
		public static bool operator ==(MapEntry lhs, MapEntry rhs)
        {
			return lhs.Equals(rhs);
        }

		public static bool operator !=(MapEntry lhs, MapEntry rhs)
        {
			return !(lhs.Equals(rhs));
        }		
		
		public override string ToString()
		{
			return "Key is [" + Key + "], Value is " + Value;
		}				
	}
	
	class MapTask
	{
		public List<MapEntry> Entries
		{
			get;
			private set;
		}
		
		internal MapTask()
		{
			Entries = new List<MapEntry>();
		}
		
		public void Execute(string target)
		{
			UTF8Encoding utf8 = new UTF8Encoding();
			byte[] bytes = utf8.GetBytes(target);
			foreach (byte b in bytes)
			{
				MapEntry entry = new MapEntry((char)b, 1);
				Entries.Add(entry);
			}
		}
	}
	
	class ReduceTask
	{
		public int Count
		{
			get;
			private set;
		}
		
		internal ReduceTask()
		{
			Count = 0;
		}
		
		public void Execute(ReduceInput input)
		{
			Count = 0;
			foreach (MapEntry entry in input.Entries)
			{
				Count++;
			}
			MapReduceCharCounter.emit(input, Count);
		}
	}
	
	struct ReduceInput
	{
		public char Key
		{
			get;
			private set;
		}
		
		public List<MapEntry> Entries
		{
			get;
			private set;
		}
		
		internal ReduceInput(char inputKey)
			: this()
		{
			Key = inputKey;
			Entries = new List<MapEntry>();
		}
	}
	
	class ReduceInputListFactory
	{
		public static List<ReduceInput> CreateInstance(List<MapEntry> entries)
		{
			List<ReduceInput> instance = new List<ReduceInput>();
			
			MapEntry? current;
			ReduceInput ri;
			
			foreach (MapEntry entry in entries)
			{
				if (!entry.Equals(current))
				{
					current = entry;
					ri = new ReduceInput(entry.Key);
					instance.Add(ri);
				}
				ri.Entries.Add(entry);
			}
			
			return instance;
		}
	}
	
	class MapReduceCharCounter
	{
		private readonly static int[] CharCount = new int[128];
		
		public static void emit(ReduceInput input, int count)
		{
			CharCount[input.Key] = count;
		}
		
		internal MapReduceCharCounter(string target)
		{
			if (target != null)
			{
				Count(target);
			}
		}
		
		private void Count(string target)
		{
			MapTask map = new MapTask();
			map.Execute(target);
			map.Entries.Sort();
			
			ReduceTask reduce = new ReduceTask();
			List<ReduceInput> inputList = ReduceInputListFactory.CreateInstance(map.Entries);
			foreach (ReduceInput input in inputList)
			{
				reduce.Execute(input);
			}
		}
		
		public int GetCharCount(char c)
		{
			int index = (int)c;
			return CharCount[index];
		}
	}
	
	public class MapReduceCharCounterMain
	{
		static void Main(string[] args)
		{
			var target = "abcaba";
			// var target2 = "abcacbaabbcbacbacbaabbbabcbacbabab";
			
			MapReduceCharCounter counter = new MapReduceCharCounter(target);
			
			Console.WriteLine("a:" + counter.GetCharCount('a'));
			Console.WriteLine("b:" + counter.GetCharCount('b'));
			Console.WriteLine("c:" + counter.GetCharCount('c'));
		}
	}
}

