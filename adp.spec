Name:     adp
Version:  0.1
Release:  alt1

Summary:  ALT Domain Policy
License:  GPL-3.0+
Group:    Other
Url:      http://altlinux.org/adp

Packager: Andrey Cherepanov <cas@altlinux.org>

Source:   %name-%version.tar

BuildRequires: rpm-build-python3
Requires: krb5-kinit
Requires: samba-common-tools
Requires: %name-templates

BuildArch: noarch

%description
Apply Linux-specific domain policies for Active Directory user or machine.

%package templates
Summary: Set of ALT Domain Policies templates
Group: Other

%description templates
Set of ALT Domain Policies templates.

%prep
%setup

%install
install -Dm 0755 adp %buildroot%_bindir/adp
install -Dm 0755 adp-functions %buildroot%_bindir/adp-functions
mkdir -p %buildroot%_prefix/libexec/%name
cp -av templates/* %buildroot%_prefix/libexec/%name
install -d -m 0770 %buildroot%_logdir/%name
install -Dm0644 %name.desktop %buildroot%_sysconfdir/xdg/autostart/%name.desktop
install -Dm0644 %name.service %buildroot%_unitdir/%name.service

%files
%doc *.md
%doc examples
%_bindir/%name
%_bindir/adp-functions
%dir %_prefix/libexec/%name
%attr(0770, root, users) %_logdir/%name
%_sysconfdir/xdg/autostart/%name.desktop
%_unitdir/%name.service

%files templates
%_prefix/libexec/%name/*

%changelog
* Wed Sep 18 2019 Andrey Cherepanov <cas@altlinux.org> 0.1-alt1
- Initial build in Sisyphus
