using System.Collections.Generic;

namespace SaveAnalyser
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

		private ParsedCodeBase parsedCodeBase;

		private void btnParse_Click(object sender, EventArgs e)
		{
			try
			{
				FolderBrowserDialog dialog = new FolderBrowserDialog();
				DialogResult result = dialog.ShowDialog();
				// Bad result
				if (result != DialogResult.OK)
					return;
				Thread processorThread = new Thread(() => {
					try
					{
						// Parse the codebase files
						parsedCodeBase = new ParsedCodeBase();
						//Screw parallel, it just uses 100% of the CPU and lags my youtube on the second screen
						string[] files = Directory.GetFiles(dialog.SelectedPath, "*.dm", SearchOption.AllDirectories);
						int lastRecorded = 0;
						for (int i = 0; i < files.Length; i++)
						{
							string fileText = File.ReadAllText(files[i]);
							parsedCodeBase.ParseFile(files[i], fileText);
							Invoke(() => {
								txtLog.Text = files[i];
							});
							int amount = (int)((i / (double)files.Length) * 100);
							if (amount > lastRecorded)
							{
								lastRecorded = amount;
								Invoke(() =>
								{
									prog.Value = amount;
									prog.Maximum = 100;
								});
							}
						}
						// Draw the tree structure (Don't care about datums for ease)
						TreeNode root = new TreeNode("/obj");
						Queue<(TreeNode, ParsedDatum)> buildQueue = new Queue<(TreeNode, ParsedDatum)>();
						buildQueue.Enqueue((root, parsedCodeBase.GetOrCreate("/obj")));
						while (buildQueue.Count > 0)
						{
							(TreeNode, ParsedDatum) top = buildQueue.Dequeue();
							//Colour it accordingly
							top.Item1.BackColor = (top.Item2.GetVar("flags_1")?.ToString()?.Contains("SAVE_SAFE_1") ?? false)
								? Color.LightGreen
								: Color.PaleVioletRed;
							foreach (ParsedDatum child in top.Item2.Children)
							{
								TreeNode createdNode = new TreeNode(child.Typepath);
								top.Item1.Nodes.Add(createdNode);
								buildQueue.Enqueue((createdNode, child));
							}
						}
						Invoke(() => {
							trvCodebase.Nodes.Clear();
							trvCodebase.Nodes.Add(root);
							prog.Value = 0;
						});
					}
					// How to truly handle errors elegantly :^)
					catch (Exception err)
					{
						MessageBox.Show(err.ToString(), "An error occurred.", MessageBoxButtons.OK, MessageBoxIcon.Error);
					}
				});
				processorThread.Start();
			}
			// How to truly handle errors elegantly :^)
			catch (Exception err)
			{
				MessageBox.Show(err.ToString(), "An error occurred.", MessageBoxButtons.OK, MessageBoxIcon.Error);
			}
		}

		/*
		private void btnToggle_Click(object sender, EventArgs e)
		{
			try
			{
				string? nodeName = trvCodebase.SelectedNode?.Name;
				if (nodeName == null)
					return;
				if (!parsedCodeBase.ParsedDatums.ContainsKey(nodeName))
					return;
				ParsedDatum selectedDatum = parsedCodeBase.ParsedDatums[nodeName];
				// Try to edit the code to toggle the save flag
			}
			// How to truly handle errors elegantly :^)
			catch (Exception err)
			{
				MessageBox.Show(err.ToString(), "An error occurred.", MessageBoxButtons.OK, MessageBoxIcon.Error);
			}
		}
		*/
	}
}
