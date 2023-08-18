/*
 * Copyright (C) 2012 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by Pawel Stolowski <pawel.stolowski@canonical.com>
 */

namespace Keyboard.InputMethodPage {
    private const string APTD_DBUS_NAME = "org.debian.apt";
    private const string APTD_DBUS_PATH = "/org/debian/apt";

    /**
    * Expose a subset of org.debian.apt interfaces -- only what's needed by applications lens.
    */
    [DBus (name = "org.debian.apt")]
    public interface AptdService : GLib.Object {
        public abstract async string install_packages (string[] packages) throws GLib.Error;
        public abstract async string remove_packages (string[] packages) throws GLib.Error;
        public abstract async void quit () throws GLib.Error;
    }

    [DBus (name = "org.debian.apt.transaction")]
    public interface AptdTransactionService : GLib.Object {
        public abstract void run () throws GLib.Error;
        public abstract void simulate () throws GLib.Error;
        public abstract void cancel () throws GLib.Error;
        public signal void finished (string exit_state);
        public signal void property_changed (string property, Variant val);
    }

    public class AptdProxy : GLib.Object {
        private AptdService _aptd_service;

        public void connect_to_aptd () throws GLib.Error {
            _aptd_service = Bus.get_proxy_sync (BusType.SYSTEM, APTD_DBUS_NAME, APTD_DBUS_PATH);
        }

        public async string install_packages (string[] packages) throws GLib.Error {
            string res = yield _aptd_service.install_packages (packages);
            return res;
        }

        public async string remove_packages (string[] packages) throws GLib.Error {
            string res = yield _aptd_service.remove_packages (packages);
            return res;
        }

        public async void quit () throws GLib.Error {
            yield _aptd_service.quit ();
        }
    }

    public class AptdTransactionProxy : GLib.Object {
        public signal void finished (string transaction_id);
        public signal void property_changed (string property, Variant variant);

        private AptdTransactionService _aptd_service;

        public void connect_to_aptd (string transaction_id) throws GLib.Error {
            _aptd_service = Bus.get_proxy_sync (BusType.SYSTEM, APTD_DBUS_NAME, transaction_id);
            _aptd_service.finished.connect ((exit_state) => {
                debug ("aptd transaction finished: %s\n", exit_state);
                finished (transaction_id);
            });
            _aptd_service.property_changed.connect ((prop, variant) => {
                property_changed (prop, variant);
            });
        }

        public void simulate () throws GLib.Error {
            _aptd_service.simulate ();
        }

        public void run () throws GLib.Error {
            _aptd_service.run ();
        }

        public void cancel () throws GLib.Error {
            _aptd_service.cancel ();
        }
    }
}
