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
	[PluginInfo(Name = "ConnectNeighbors", Category = "Spread", Version = "1", Help = "Basic template with one value in/out", Tags = "")]
	#endregion PluginInfo
	public class C1SpreadConnectNeighborsNode : IPluginEvaluate
	{
		#region fields & pins
		[Input("Input")]
		public ISpread<Vector3D> IInput;
		
		[Input("radius", DefaultValue = 1.0, IsSingle = true)]
		public ISpread<float> IRadius;

		[Output("Vertices")]
		public ISpread<Vector3D> OVertices;

		[Output("Indices")]
		public ISpread<int> OIndices;
		
		[Output("Distance")]
		public ISpread<float> ODistance;
		
		List<Vector3D> vertices = new List<Vector3D>();
		List<int> indices = new List<int>();
		List<float> distance = new List<float>();
		
		[Import()]
		public ILogger FLogger;
		#endregion fields & pins

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			//for each frame empty the lists
			vertices.Clear();
			indices.Clear();
			distance.Clear();

			float radius = IRadius[0];

			//for every incoming vector...
			for (int i = 0; i < SpreadMax; i++)
			{
				//check every other incoming vector...
				for (int j = i + 1; j < SpreadMax; j++)
				{
					float dist = (float) VMath.Dist(IInput[i], IInput[j]);
					if (dist < radius) {
						vertices.Add(IInput[i]);
						vertices.Add(IInput[j]);
						indices.Add(i);
						indices.Add(j);
						distance.Add(dist / radius);
					}
				}
			}

			OVertices.AssignFrom(vertices);
			OIndices.AssignFrom(indices);
			ODistance.AssignFrom(distance); 
		}
	}
}
