using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading;

namespace PrefGPU
{
	class MainClass
	{
		[DllImport("kernel32.dll")]
		static extern IntPtr GetConsoleWindow();
		[DllImport("user32.dll")]
		static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
		
		const int SW_HIDE = 0;
		static int CURRENT_SETTINGS;

		public static void Main(string[] args) {

			var handle = GetConsoleWindow();
			ShowWindow(handle, SW_HIDE);
			if (args.Length != 2) {
				Message.Show("Missing required arguments\nfound:"+args.Length+"\nrequired:2", Message.Error);
				return;
			}

			string app = args[0];
			if (!File.Exists(app)) {
				Message.Show("The executable does not exists", Message.Error);
				return;
			}

			string gpu_id = args[1];
			if (Convert.ToInt32(gpu_id) > 5 || Convert.ToInt32(gpu_id) < 0) {
				Message.Show("Invalid GPU ID", Message.Error);
				return;
			}

            CURRENT_SETTINGS = getCurrentSettings(app);
			Console.WriteLine(CURRENT_SETTINGS);

			bool is_permenent = false;
			if (Convert.ToInt32(gpu_id) > 2){
				// Permenent
				gpu_id = Convert.ToString(Convert.ToInt32(gpu_id) - 3);
				is_permenent = true;

			}

			setGPU(app, gpu_id);
			Thread.Sleep(1000);
			runApp(app, "");
			

			if (!is_permenent){
				setGPU(app, CURRENT_SETTINGS.ToString());
			}
		}

		private static int getCurrentSettings(string file) { 
		
			Microsoft.Win32.RegistryKey key;
			key = Microsoft.Win32.Registry.CurrentUser.OpenSubKey("Software\\Microsoft\\DirectX\\UserGpuPreferences");
			foreach (string val in key.GetValueNames()) {
				if (file == val){
					string preferred_gpu = key.GetValue(file).ToString();
					key.Close();

					if (preferred_gpu.Contains("GpuPreference=2")) {
						return 2;
					}

					if (preferred_gpu.Contains("GpuPreference=1")) {
						return 1;
					}
				}
			}
			return 0;
		}

		private static int setGPU(string name, string val) {

			Process runProg = new Process();
			string reg_key = @"HKCU\Software\Microsoft\DirectX\UserGpuPreferences";
			string command = "ADD \"" + reg_key + "\" /v \"" + name + "\" /t REG_SZ /d \"GpuPreference=" + val + "\" /f";
			try
			{
				runProg.StartInfo.FileName = "reg";		    
				runProg.StartInfo.CreateNoWindow = false;
				runProg.StartInfo.UseShellExecute = false;
				runProg.StartInfo.WindowStyle = ProcessWindowStyle.Normal;
				runProg.StartInfo.Arguments = command;
				runProg.StartInfo.RedirectStandardOutput = true;
				runProg.Start();

				while (!runProg.StandardOutput.EndOfStream) {
					string line = runProg.StandardOutput.ReadLine();
				}

				return runProg.ExitCode;

			} catch (Exception ex) {
				Message.Show("Could not modify the register\n" + ex, Message.Error);
				return 1;
			}
		}

		private static void runApp(string file, string arg) { 
		
			Process runProg = new Process();
			try {
				runProg.StartInfo.FileName = file;
				runProg.StartInfo.WorkingDirectory = file.Substring(0, file.LastIndexOf("\\", StringComparison.CurrentCulture));
				runProg.StartInfo.CreateNoWindow = false;
				runProg.StartInfo.UseShellExecute = false;
				runProg.StartInfo.WindowStyle = ProcessWindowStyle.Normal;
				
				if (arg.Length > 0) {
					runProg.StartInfo.Arguments = arg;
				}

			    runProg.Start();
				runProg.WaitForExit();
			}
			catch (Exception ex) {
				Message.Show("Could not start the executable\n" + ex, Message.Error);
			}
		}
	}


	public static class Message
	{
	    public static readonly System.Windows.Forms.MessageBoxIcon Info = System.Windows.Forms.MessageBoxIcon.Information;
	    public static readonly System.Windows.Forms.MessageBoxIcon Error = System.Windows.Forms.MessageBoxIcon.Error;
	    public static readonly System.Windows.Forms.MessageBoxIcon Warning = System.Windows.Forms.MessageBoxIcon.Warning;
	    public static readonly System.Windows.Forms.MessageBoxIcon None = System.Windows.Forms.MessageBoxIcon.None;

	    public static void Show(string message, System.Windows.Forms.MessageBoxIcon icon = System.Windows.Forms.MessageBoxIcon.None)
	    {
	        string title;
	        switch (icon)
	        {
	            case System.Windows.Forms.MessageBoxIcon.Information:
	                title = "Information";
	                break;
	            case System.Windows.Forms.MessageBoxIcon.Error:
	                title = "Error";
	                break;
	            case System.Windows.Forms.MessageBoxIcon.Warning:
	                title = "Warning";
	                break;
	            default:
	                title = "Message";
	                break;
	        }

	        System.Windows.Forms.MessageBox.Show(message, title, System.Windows.Forms.MessageBoxButtons.OK, icon);
	    }
	}
}
