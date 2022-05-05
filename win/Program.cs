/*
    This file is part of tdm-launcher.
    Copyright 2022 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE,
    Miniature Mobile Robots group, Switzerland
    Author: Yves Piguet
*/

using System;
using System.Windows.Forms;
using System.Diagnostics;
using System.ComponentModel;
using System.Threading;

public class MainForm: System.Windows.Forms.Form
{
    private System.Windows.Forms.NotifyIcon notifyIcon;
    private System.ComponentModel.IContainer components;

	private Process process;

    [STAThread]
    static void Main()
    {
		using (var singleApp = new Mutex(false, "org.mobsya.tdmlauncher"))
			if (singleApp.WaitOne(TimeSpan.Zero))
				Application.Run(new MainForm());
    }

	public MainForm()
    {
		System.Windows.Forms.ContextMenu contextMenu = new System.Windows.Forms.ContextMenu();
		System.Windows.Forms.MenuItem menuItemExit = new System.Windows.Forms.MenuItem();

        contextMenu.MenuItems.AddRange(
            new System.Windows.Forms.MenuItem[] {menuItemExit});

        menuItemExit.Index = 0;
        menuItemExit.Text = "E&xit";
        menuItemExit.Click += new System.EventHandler(this.Exit);

		// window title, in case it appears somewhere (window itself is hidden by OnLoad)
		this.Text = TDMLauncher.Properties.Resources.TDMName;

		this.components = new System.ComponentModel.Container();
		notifyIcon = new System.Windows.Forms.NotifyIcon(this.components);

		notifyIcon.Icon = TDMLauncher.Properties.Resources.Thymio;
		notifyIcon.ContextMenu = contextMenu;
		notifyIcon.Text = TDMLauncher.Properties.Resources.TDMName;
		notifyIcon.Visible = true;
	}

	private void LaunchTDM()
	{
		ProcessStartInfo info = new ProcessStartInfo();
		info.FileName = TDMLauncher.Properties.Resources.TDMPath;
		info.WindowStyle = ProcessWindowStyle.Hidden;
		info.CreateNoWindow = true;

		try
		{
			this.process = Process.Start(info);
		}
		catch (System.ComponentModel.Win32Exception)
		{
			// failure: change icon
			notifyIcon.Icon = TDMLauncher.Properties.Resources.Thymio_crossed;
		}
	}

	protected override void OnLoad(EventArgs e)
	{
		Visible = false;
		ShowInTaskbar = false;
		base.OnLoad(e);

		LaunchTDM();
	}

	protected override void Dispose(bool disposing)
	{
		if (disposing && components != null)
			components.Dispose();

		base.Dispose(disposing);
	}

	private void Exit(object Sender, EventArgs e)
	{
		if (this.process != null)
		{
			// should send a gentle shutdown request message via tcp instead of killing
			try
			{
				this.process.Kill();
				this.process.WaitForExit();
			}
			catch (InvalidOperationException)
			{
				// ignore, process was already terminated
			}
		}

		// exit
		this.Close();
	}
}
