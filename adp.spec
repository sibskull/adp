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

BuildArch: noarch

%description
Apply Linux-specific domain policies for Active Directory user or machine.

%prep
%setup

%install
install -Dm 0644 adp %buildroot%_bindir/adp
mkdir -p %buildroot%_prefix/libexec/%name
cp -av policies/* %buildroot%_prefix/libexec/%name
install -d -m 0770 %buildroot%_logdir/%name

%files
%doc *.md
%_bindir/%name
%_prefix/libexec/%name
%attr(0770, root, users) %_logdir/%name

%changelog
* Wed Sep 18 2019 Andrey Cherepanov <cas@altlinux.org> 0.1-alt1
- Initial build in Sisyphus
