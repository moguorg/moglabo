/**
 * This is "Collective Intelligence" library for studying oneself.
 * Reference:
 * 「集合知プログラミング(O'REILLY)」
 **/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace CI
{
	public class Feature
	{
		public string Term
		{
			get;
			private set;
		}
		
		public int Count
		{
			get;
			private set;
		}		
		
		public Feature(string term, int count)
		{
			Term = term;
			Count = count;
		}	
		
		public override bool Equals(object o)
		{
			Feature f = o as Feature;
			
			if (f != null)
			{		
				return Term.Equals(f.Term) && Count == f.Count;
			}
			else
			{
				return false;
			}
		}
		
		public override int GetHashCode()
		{
			return Term.GetHashCode()^Count;
		}		
		
		public override string ToString()
		{
			return "Feature term is [" + Term + "], that count is " + Count;
		}		
	}
	
	/// <summary>
	/// Basic classifier class
	/// </summary>
	public class Classifier
	{
		protected readonly Func<string, Dictionary<string, int>> GetFeatures;
		private Dictionary<string, Dictionary<string, int>> FeatureOverCatrgoryCount;
		private Dictionary<string, int> CategoryCount;
		
		private readonly double Weight = 1.0;
		private readonly double Ap = 0.5;
	
		public Classifier(){ }	
	
		public Classifier(Func<string, Dictionary<string, int>> func, string fileName)
		{
			GetFeatures = func;
			FeatureOverCatrgoryCount = new Dictionary<string, Dictionary<string, int>>();
			CategoryCount = new Dictionary<string, int>();
		}
		
		public void Incf(string feature, string category)
		{
			if (!FeatureOverCatrgoryCount.ContainsKey(feature))
			{
				FeatureOverCatrgoryCount[feature] = new Dictionary<string, int>();
			}
			
			if (!FeatureOverCatrgoryCount[feature].ContainsKey(category))
			{
				FeatureOverCatrgoryCount[feature][category] = 0;
			}
			
			FeatureOverCatrgoryCount[feature][category] += 1;
		}

		public void Incc(string category)
		{
			if (!CategoryCount.ContainsKey(category))
			{
				CategoryCount[category] = 0;
			}
			
			CategoryCount[category] += 1;
		}

		public double FCount(string feature, string category)
		{
			if (FeatureOverCatrgoryCount.ContainsKey(feature) && 
			FeatureOverCatrgoryCount[feature].ContainsKey(category))
			{
				double fc = FeatureOverCatrgoryCount[feature][category];
				return fc;
			}
			return 0.0;
		}

		public int CatCount(string category)
		{
			if (!CategoryCount.ContainsKey(category))
			{
				return 0;
			}
			
			return CategoryCount[category];
		}
		
		public int TotalCount()
		{
			return CategoryCount.Values.Sum();
		}

		private Dictionary<string, int>.KeyCollection Categories()
		{
			return CategoryCount.Keys;
		}
		
		public double FProb(string feature, string category)
		{
			int catcnt = CatCount(category);
			if (catcnt == 0)
			{
				return 0.0;
			}
			
			return FCount(feature, category) / catcnt;
		}
		
		public double WeightedProb(string feature, string category, Func<string, string, double> probFunc)
		{
			double nowProb = probFunc(feature, category);
			
			double totals = 0.0;
			foreach (var cat in Categories()) /* @TODO: use LINQ; */
			{
				totals += FCount(feature, cat);
			}
			
			double bp = ((Weight * Ap) + (totals * nowProb)) / (Weight + totals);
			
			return bp;
		}
		
		public void Train(string sample, string category)
		{
			var features = GetFeatures(sample);
			
			foreach (var feature in features) /* @TODO: use LINQ; */
			{
				Incf(feature.Key, category);
			}
			Incc(category);
		}
		
		/* for test */
		public void SampleTrain()
		{
			Train("Nobady owns the water.", "good");
			Train("the quick rabbit jumps fences.", "good");
			Train("buy pharmaceuticals now", "bad");
			Train("make quick money at the online casino", "bad");
			Train("the quick brown fox jumps", "good");
		}
	}
	
	public class NaiveBays : Classifier
	{
		public NaiveBays(Func<string, Dictionary<string, int>> func, string fileName) 
		: base(func, fileName)
		{
		}
	
		private double DocProb(string item, string category)
		{
			var features = GetFeatures(item);
			
			double prob = 1.0;
			foreach (var feature in features)
			{
				prob *= WeightedProb(feature.Key, category, FProb);
			}
			
			return prob;
		}
	
		public double Prob(string item, string category)
		{
			double categoryProb = CatCount(category) / TotalCount();
			double docp = DocProb(item, category);
			return categoryProb * docp;
		}
	}
	
	public class DocumentFiltering
	{
		private static bool IsAcceptWord(string word)
		{
			return !string.IsNullOrEmpty(word) && 
					2 < word.Length && word.Length < 20;
		}
	
		public static Dictionary<string, int> GetWords(string doc)
		{
			Dictionary<string, int> result = new Dictionary<string, int>();
			Regex splitter = new Regex(@"[\n\r,.\(\)\s\t]+", RegexOptions.Multiline);
			string[] words = splitter.Split(doc);
			
			var wordRecords = 
				from word in words 
				where IsAcceptWord(word) 
				group word by word.ToLower() into grp 
				orderby grp.Count() 
				select new { Count = grp.Count(), Word = grp.Key };
			
			foreach (var record in wordRecords)
			{
				result.Add(record.Word, record.Count);
			}
			
			return result;
		}
	}
}

