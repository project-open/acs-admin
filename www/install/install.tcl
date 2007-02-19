ad_page_contract {
    Install from local file system
} {
    package_type:optional
    {upgrade_p 0}
    {repository_url ""}
}


if { ![empty_string_p $repository_url] } {
    set page_title "Install From OpenACS Repository"
} else {
    set page_title "Install From Local File System"
}

set context [list [list "." "Install Software"] $page_title]


#####
#
# Get list of packages available for install/upgrade
#
#####

apm_get_installed_versions -array installed_versions
set upgrades_p 0
array set package [list]

apm_get_package_repository -repository_url $repository_url -array repository

foreach package_key [array names repository] {
    array unset version
    array set version $repository($package_key)

    if { ![exists_and_not_null package_type] || [string equal $version(package.type) $package_type] } {
        set package_key $version(package.key)
            
        # If in upgrade mode, only add to list if it's an upgrade
        if { !$upgrade_p || [string equal $version(install_type) upgrade] } {
            set package([string toupper $version(package-name)]) \
                [list \
                     $version(package.key) \
                     $version(package-name) \
                     $version(name) \
                     $version(package.type) \
                     $version(install_type) \
                     $version(summary)]
        }
    }
}


#####
#
# Output the list
#
#####

# Sort the list alphabetically (in case package_name and package_key doesn't sort the same)
multirow create packages package_key package_name version_name package_type install_type summary
foreach name [lsort -ascii [array names package]] {
    set row $package($name)
    multirow append packages \
        [lindex $row 0] \
        [lindex $row 1] \
        [lindex $row 2] \
        [lindex $row 3] \
        [lindex $row 4] \
        [lindex $row 5]
}

multirow extend packages install_url
multirow -unclobber foreach packages {
    set install_url [export_vars -base install-2 { package_key repository_url }]
}


# Build the list-builder list
template::list::create \
    -name packages \
    -multirow packages \
    -key package_key \
    -bulk_actions {
        "Install checked applications" "install-2" "Install checked applications"
    } \
    -bulk_action_export_vars {
        repository_url
    } \
    -elements {
        package_name {
            label "Package"
            link_url_col install_url
            link_html { title "Install this package" }
        }
        summary {
            label "Summary"
        }   
        version_name {
            label "Version"
        }
        package_type {
            label "Type"
            display_eval {[ad_decode $package_type "apm_application" "Application" "Service"]}
        }
        upgrade {
            label "Upgrade"
            hide_p {[ad_decode $upgrades_p 1 0 1]}
            display_eval {[ad_decode $install_type "upgrade" "Upgrade" ""]}
        }
    } -filters {
        package_type {
            label "Type"
            values {
                {Application apm_application}
                {Service apm_service}
            }
        }
        upgrade_p {
            label "Upgrade"
            values {
                {"Install" 0}
                {"Upgrade" 1}
            }
            default_value 0
        }
        repository_url {
            hide_p 1
        }
    }

