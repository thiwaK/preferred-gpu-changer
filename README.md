# Preferred GPU Changer
A lightweight application that restores the "Run with graphics processor" context menu option, allowing you to easily select a preferred GPU for any application without navigating through complex settings.

---
### ✨ Background
With the release of the Windows 10 May 2020 Update (20H1), Microsoft altered how users can select a GPU for specific applications. As a result, the familiar "Run with graphics processor" option was removed from the NVIDIA Control Panel and the right-click context menu.

Now, to force an application to use a specific GPU, users must:
1. Open Windows **Display Settings**.
2. Navigate to **Graphics Settings** under **Advanced Display Settings**.
3. **Browse** for the application's executable file.
4. **Select** the application and click **Options** to open the GPU selection window.
5. **Choose** the preferred **GPU** and save the settings.

While this method works, it is tedious, especially if you need to frequently switch GPUs for different applications.

To simplify this process, I developed an application that restores the **"Run with graphics processor"** option to the right-click context menu. This tool allows you to select the GPU directly from the context menu, just like before.

---
### 🛠️ How It Works
The Preferred GPU Changer application works by directly modifying the Windows Registry to set the GPU preference for a specific application.

The application checks the current GPU preference for the specified application by querying the Windows Registry:
* It opens the registry key: `HKEY_CURRENT_USER\Software\Microsoft\DirectX\UserGpuPreferences`.
* It searches for the application name within the registry values and checks the GPU preference associated with it.

The possible GPU preference values are:
- `GpuPreference=0`: Let Windows Choose
- `GpuPreference=1`: Power Saving GPU
- `GpuPreference=2`: High Performance GPU

If no preference is found, it defaults to `GpuPreference=0`, which means the system chooses automatically.

Once the current GPU setting is retrieved, the application sets the new GPU preference by adding a new registry entry or modifying the existing one. After updating the GPU preference, the application is then launched.

---
### ⚙️ Getting Started
1. Download the Installer
   * Visit the [Releases page](https://github.com/thiwaK/preferred-gpu-changer/releases) of this repository to download the latest installer.

2. Install the Application
   * Once the installer is downloaded, run it and follow the on-screen instructions to complete the installation.

3. Use the Context Menu Option
   * After installation, simply right-click on any executable (.exe) file or application.
   * You will see a "Run with graphics processor" option in the context menu. Select it to choose the GPU you want to use for that application.


---
### 🔧 Usage
Right-click on the executable file or its shortcut to open the context menu. You’ll see the following options


**Temporary GPU Settings**
These options apply only while the application is running. The settings revert to default once the application is closed:
- `High Performance`: Runs the application on the high-performance GPU.
- `Power Saving`: Runs the application on the power-saving GPU.

**Permanent GPU Settings**
These options set a permanent GPU preference for the application, lasting until changed via this menu or Windows Graphics Settings:
- `Default (Permanent)`: Resets the GPU preference to the system default.
- `High Performance (Permanent)`: Forces the application to always use the high-performance GPU.
- `Power Saving (Permanent)`: Forces the application to always use the power-saving GPU.

**Note**: Temporary settings are ideal for one-time tasks, while permanent settings are useful for applications with specific GPU requirements.

---
### 🚀 Contribution
Contributions are welcome! Feel free to open issues, submit PRs, or suggest improvements to make this tool more valuable.