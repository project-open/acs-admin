ad_page_contract {

    Kill (restart) the server.

    @author Peter Marklund (peter@collaboraid.biz)
    @creation-date 27:th of March 2003
    @cvs-id $Id$
}

set page_title "Restarting Server"

set context [list $page_title]


# We do this as a schedule proc, so the server will have time to serve the page

global tcl_platform
set platform $tcl_platform(platform)
switch $platform {
    "windows" {
        # Restart doesn't work on Windows services, so handle it here...
        ad_schedule_proc -thread t -once t 2 ns_shutdown -restart
    }
    default {
        # Don't modify default behavior.
        # Trust Linux to handle restarts
        ad_schedule_proc -thread t -once t 2 ns_shutdown
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
