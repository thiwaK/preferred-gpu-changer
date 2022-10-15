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
		static int current_settings;

		public static void Main(string[] args) {

			var handle = GetConsoleWindow();
			ShowWindow(handle, SW_HIDE);
			if (args.Length < 2) {
				Console.WriteLine("Invalid arguments:"+args.Length);Console.ReadKey();
				return;
			}
			string app = args[0];
			string gpu_id = args[1];
			if (!File.Exists(app)) {
				Console.WriteLine("App not exists");Console.ReadKey();
				return;
			}

            current_settings = GetCurrentSettings(app);
			Console.WriteLine(current_settings);
			Console.WriteLine(SetGPU(app, gpu_id));
			Thread.Sleep(1000);
            RunApp(app, "");
			Console.WriteLine();
			//Console.ReadKey();

		}

		private static int GetCurrentSettings(string file) { 
		
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

		private static int SetGPU(string name, string val) {

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
					//Console.WriteLine(line);
				}

				return runProg.ExitCode;

			} catch (Exception ex) {
				Console.WriteLine("Could not start program " + ex);
				return 1;
			}
		}

		private static void RunApp(string file, string arg) { 
		
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

				SetGPU(file, current_settings.ToString());
			}
			catch (Exception ex)
			{
				Console.WriteLine("Could not start program " + ex);
			}
		
		}


	}
}
