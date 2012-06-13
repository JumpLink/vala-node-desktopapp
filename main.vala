//valac --vapidir ./vapi --pkg gtk+-3.0 --pkg posix --pkg webkitgtk-3.0 --pkg gee-1.0 --pkg gio-2.0 --thread main.vala theme.vala client-communicate.vala

using Gtk;
using WebKit;
using Posix;

public class ValaBrowser {

    private const string TITLE = "Vala Browser";
    private const string HOME_URL = "http://localhost:3000/";
    private const string DEFAULT_PROTOCOL = "http";

    private Regex protocol_regex;

    //private Entry url_bar;
    private WebView web_view;
    private Window window;
    //private Label status_bar;
    //private ToolButton back_button;
    //private ToolButton forward_button;
    //private ToolButton reload_button;

    public ValaBrowser () {
        //this.window.title = ValaBrowser.TITLE;
        //window.set_default_size (800, 600);

        try {
            this.protocol_regex = new Regex (".*://.*");
        } catch (RegexError e) {
            critical ("%s", e.message);
        }

        create_widgets ();
        connect_signals ();
        //this.url_bar.grab_focus ();

        // print(@"window-border: $(window.border_width)\n");
        // print(@"web_view-border: $(web_view.border_width)\n");
    }

    private bool create_widgets () {
        this.web_view = new WebView ();
        ScrolledWindow scrolled_window;
        try {
            // If the UI contains custom widgets, their types must've been instantiated once
            // Type type = typeof(Foo.BarEntry);
            // assert(type != 0);
            var builder = new Builder ();
            builder.add_from_file ("ui/window.ui");
            builder.connect_signals (null);
            window = builder.get_object ("window") as Window;
            window.maximize();
            //window.fullscreen();
            scrolled_window = builder.get_object ("scrolledwindow") as ScrolledWindow;
            //print(@"scrolled_window-padding: $(scrolled_window.top_padding)\n");
            //print(@"scrolled_window-border: $(scrolled_window.border_width)\n");
            window.show_all ();
        } catch (Error e) {
            print ("Could not load UI: %s\n", e.message);
            return true;
        } 

        scrolled_window.add (this.web_view);
        //window.add (this.web_view);

        return false;
    }

    private void exit() {
        // exit start.sh and node
        try {
            GLib.Process.spawn_command_line_async("killall start.sh");
            GLib.Process.spawn_command_line_async("killall node");
        } catch (GLib.SpawnError e) {
            print("Error: %s\n", e.message);
        }
        // exit this app
        Gtk.main_quit();
    }

    private void client_communicate(string text) {
        print("Statusbar: %s",text);
        switch (text) {
            case "fullscreen":
                window.fullscreen();
                break;
            case "unfullscreen":
                window.unfullscreen();
                break;
            case "reload":
                web_view.reload();
                break;
            case "back":
                this.web_view.go_back();
                break;
            case "forward":
                this.web_view.can_go_forward ();
                break;
        }
    }

    private void connect_signals () {
        this.window.destroy.connect (exit);
        //this.url_bar.activate.connect (on_activate);
        this.web_view.title_changed.connect ((source, frame, title) => {
            //this.title = "%s - %s".printf (title, ValaBrowser.TITLE);
        });
        this.web_view.load_committed.connect ((source, frame) => {
            //this.url_bar.text = frame.get_uri ();
            //update_buttons ();
        });
        this.web_view.status_bar_text_changed.connect(client_communicate);

        //this.back_button.clicked.connect (this.web_view.go_back);
        //this.forward_button.clicked.connect (this.web_view.go_forward);
        //this.reload_button.clicked.connect (this.web_view.reload);
    }

    // private void update_buttons () {
    //     this.back_button.sensitive = this.web_view.can_go_back ();
    //     this.forward_button.sensitive = this.web_view.can_go_forward ();
    // }

    // private void on_activate () {
    //     var url = this.url_bar.text;
    //     if (!this.protocol_regex.match (url)) {
    //        url = "%s://%s".printf (ValaBrowser.DEFAULT_PROTOCOL, url);
    //     }
    //     this.web_view.open (url);
    // }

    public void start () {
        this.window.show_all ();
        this.web_view.open (ValaBrowser.HOME_URL);
    }

    public static int main (string[] args) {
        Gtk.init (ref args);

        var browser = new ValaBrowser ();
        browser.start ();

        Theme theme = new Theme(browser.window);
        if (args[1] == "--load-icons" )
            theme.saveImages();
        /* run nodejs */
        try {
            GLib.Process.spawn_command_line_async("./start.sh");
            Posix.sleep(2);
        } catch (GLib.SpawnError e) {
            print("Error: %s\n", e.message);
        }
        
        Gtk.main ();

        return 0;
    }
}