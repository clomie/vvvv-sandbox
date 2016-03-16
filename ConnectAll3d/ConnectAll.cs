#region usings
using System;
using System.Collections.Generic;
using System.ComponentModel.Composition;

using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;
using VVVV.Utils.VColor;
using VVVV.Utils.VMath;

using VVVV.Core.Logging;
#endregion usings

namespace VVVV.Nodes
{
	#region PluginInfo
	[PluginInfo(Name = "ConnectAll", 
				Category = "3d", 
				Help = "Returns pairs of vertices that have a distance less than the given radius.")]
	#endregion PluginInfo
	public class ConnectAll : IPluginEvaluate
	{
		#region fields & pins
		[Input("Input")]
		ISpread<Vector3D> FInput;
		
		[Input("Max Radius", DefaultValue = 1)]
		ISpread<double> FMaxRadius;

		[Output("Output")]
		ISpread<Vector3D> FOutput;
		
		[Output("Index")]
		ISpread<int> FIndex;
		
		[Output("Distance")]
		ISpread<double> FDistance;

		//the internal list used to store vectors with a distance 
		//less than the given radius
		List<Vector3D> FDots = new List<Vector3D>();
		// 20160315add 
		List<int> FIndices = new List<int>();
		//another list that stores the actual distance between two points
		List<double> FDistances = new List<double>();
		#endregion fields & pins

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			//for each frame empty the lists
			FDots.Clear();
			FIndices.Clear();
			FDistances.Clear();
			
			//for every incoming vector...
			for (int i = 0; i < SpreadMax; i++)
			{
				//check every other incoming vector...
				for (int j = i + 1; j < SpreadMax; j++)
				{
					//if the distance is less than the given radius...
					var d = VMath.Dist(FInput[i], FInput[j]);

					if (d <= FMaxRadius[0])
					{
						//add both vecotors to the list
						FDots.Add(FInput[i]);
						FDots.Add(FInput[j]);
						
						//add index i
						FIndices.Add(i);
						
						//add the distace between the two vectors to the list
						FDistances.Add(d / FMaxRadius[0]);
					}
				}
			}
			
			//in beta>24.1 you can directly assign lists to pins
			FOutput.AssignFrom(FDots);
			FIndex.AssignFrom(FIndices);
			FDistance.AssignFrom(FDistances);
			
			//in beta24.1 you still have to move the list entries
			//to the output slices manually
//			FOutput.SliceCount = FDots.Count;
//			FDistance.SliceCount = FDistances.Count;
//			FIndex.SliceCount = FIndices.Count;
//				
//			for (int i = 0; i<FDots.Count; i++)
//				FOutput[i] = FDots[i];
//			
//			for (int i = 0; i<FDistances.Count; i++)
//				FDistance[i] = FDistances[i];
//			
//			for (int i = 0; i<FIndices.Count; i++)
//				FIndex[i] = FIndices[i];
		}
	}
}
