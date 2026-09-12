#!/usr/bin/env bash
# Vietnamese input: ibus + Unikey (Telex, Unicode), switch with Alt+Space.
#
# Optional: INSTALL_VI_LOCALE=1 ./scripts/08-vietnamese.sh
#   also generates the vi_VN.UTF-8 locale (the desktop language stays English).
source "$(dirname "$(dirname "$(readlink -f "$0")")")/lib.sh"

log "Installing ibus + Unikey"
apt_install ibus ibus-unikey ibus-gtk ibus-gtk3 ibus-gtk4 im-config \
            fonts-dejavu fonts-liberation

# Make ibus the system-wide input-method framework (writes ~/.xinputrc).
if have im-config; then
  im-config -n ibus >/dev/null 2>&1 && ok "ibus set as the input method framework" \
    || warn "im-config failed; ibus is Ubuntu's default anyway"
fi

# ---------------------------------------------------------------- locale
if [ "${INSTALL_VI_LOCALE:-0}" = "1" ]; then
  log "Generating the vi_VN.UTF-8 locale"
  need_sudo
  sudo locale-gen vi_VN.UTF-8
  sudo update-locale
  ok "vi_VN.UTF-8 available (LANG stays en_US.UTF-8)"
else
  ok "skipping vi_VN locale (set INSTALL_VI_LOCALE=1 to generate it)"
fi

# ---------------------------------------------------------------- GNOME settings
if [ -z "${WAYLAND_DISPLAY:-}${DISPLAY:-}" ]; then
  warn "no graphical session detected — skipping the gsettings part."
  warn "log into the desktop and re-run: ./install.sh 08"
  exit 0
fi

log "Registering the input sources (US keyboard + Unikey)"
gsettings set org.gnome.desktop.input-sources sources \
  "[('xkb', 'us'), ('ibus', 'Unikey')]"
gsettings set org.gnome.desktop.input-sources per-window false
ok "input sources set"

log "Binding the input-source switch to Alt+Space"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source \
  "['<Alt>space']"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward \
  "['<Shift><Alt>space']"
ok "Alt+Space switches EN <-> VI"

log "Configuring the Unikey engine"
u=org.freedesktop.ibus.engine.unikey
gsettings set $u input-method   'telex'     # Telex, not VNI
gsettings set $u output-charset 'unicode'
gsettings set $u spell-check            true
gsettings set $u auto-restore-non-vn    true
gsettings set $u free-marking           true
gsettings set $u standalone-w-as-uw     true
gsettings set $u macro-enabled          false
gsettings set $u modern-style           false
ok "Unikey: Telex + Unicode"

log "Restarting the ibus daemon"
if pgrep -x ibus-daemon >/dev/null; then
  ibus restart >/dev/null 2>&1 && ok "ibus restarted"
else
  (ibus-daemon -drx >/dev/null 2>&1 &) && ok "ibus started"
fi

cat <<'NOTE'

  Kiem tra: mo mot o nhap bat ky, bam Alt+Space -> icon tren thanh panel
  doi sang "VN", go "tieengs vieejt" (kieu Telex) ra "tiếng việt".

  Neu app Electron/JetBrains khong nhan bo go, dang xuat va dang nhap lai;
  neu van loi, them vao ~/.profile:
      export GTK_IM_MODULE=ibus
      export QT_IM_MODULE=ibus
      export XMODIFIERS=@im=ibus
NOTE

ok "Vietnamese input ready — log out and back in to be safe"
