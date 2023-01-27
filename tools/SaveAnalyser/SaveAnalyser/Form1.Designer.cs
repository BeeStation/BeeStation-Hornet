namespace SaveAnalyser
{
    partial class Form1
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.btnParse = new System.Windows.Forms.Button();
            this.trvCodebase = new System.Windows.Forms.TreeView();
            this.prog = new System.Windows.Forms.ProgressBar();
            this.txtLog = new System.Windows.Forms.TextBox();
            this.SuspendLayout();
            // 
            // btnParse
            // 
            this.btnParse.Location = new System.Drawing.Point(12, 12);
            this.btnParse.Name = "btnParse";
            this.btnParse.Size = new System.Drawing.Size(288, 23);
            this.btnParse.TabIndex = 0;
            this.btnParse.Text = "Parse Codebase";
            this.btnParse.UseVisualStyleBackColor = true;
            this.btnParse.Click += new System.EventHandler(this.btnParse_Click);
            // 
            // trvCodebase
            // 
            this.trvCodebase.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.trvCodebase.Location = new System.Drawing.Point(12, 41);
            this.trvCodebase.Name = "trvCodebase";
            this.trvCodebase.Size = new System.Drawing.Size(778, 532);
            this.trvCodebase.TabIndex = 1;
            // 
            // prog
            // 
            this.prog.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.prog.Location = new System.Drawing.Point(544, 12);
            this.prog.Name = "prog";
            this.prog.Size = new System.Drawing.Size(246, 23);
            this.prog.TabIndex = 2;
            // 
            // txtLog
            // 
            this.txtLog.Location = new System.Drawing.Point(306, 13);
            this.txtLog.Name = "txtLog";
            this.txtLog.Size = new System.Drawing.Size(232, 23);
            this.txtLog.TabIndex = 3;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(802, 585);
            this.Controls.Add(this.txtLog);
            this.Controls.Add(this.prog);
            this.Controls.Add(this.trvCodebase);
            this.Controls.Add(this.btnParse);
            this.Name = "Form1";
            this.Text = "Form1";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

		#endregion

		private Button btnParse;
		private TreeView trvCodebase;
		private ProgressBar prog;
		private TextBox txtLog;
	}
}
