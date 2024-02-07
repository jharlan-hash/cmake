# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
GNUInstallDirs
--------------

Define GNU standard installation directories

Provides install directory variables as defined by the
`GNU Coding Standards`_.

.. _`GNU Coding Standards`: https://www.gnu.org/prep/standards/html_node/Directory-Variables.html

Result Variables
^^^^^^^^^^^^^^^^

Inclusion of this module defines the following variables:

``CMAKE_INSTALL_<dir>``

  Destination for files of a given type.  This value may be passed to
  the ``DESTINATION`` options of :command:`install` commands for the
  corresponding file type.  It should typically be a path relative to
  the installation prefix so that it can be converted to an absolute
  path in a relocatable way (see ``CMAKE_INSTALL_FULL_<dir>``).
  However, an absolute path is also allowed.

``CMAKE_INSTALL_FULL_<dir>``

  The absolute path generated from the corresponding ``CMAKE_INSTALL_<dir>``
  value.  If the value is not already an absolute path, an absolute path
  is constructed typically by prepending the value of the
  :variable:`CMAKE_INSTALL_PREFIX` variable.  However, there are some
  `special cases`_ as documented below.

where ``<dir>`` is one of:

``BINDIR``
  user executables (``bin``)
``SBINDIR``
  system admin executables (``sbin``)
``LIBEXECDIR``
  program executables (``libexec``)
``SYSCONFDIR``
  read-only single-machine data (``etc``)
``SHAREDSTATEDIR``
  modifiable architecture-independent data (``com``)
``LOCALSTATEDIR``
  modifiable single-machine data (``var``)
``RUNSTATEDIR``
  .. versionadded:: 3.9
    run-time variable data (``LOCALSTATEDIR/run``)
``LIBDIR``
  object code libraries (``lib`` or ``lib64``)

  On Debian, this may be ``lib/<multiarch-tuple>`` when
  :variable:`CMAKE_INSTALL_PREFIX` is ``/usr``.
``INCLUDEDIR``
  C header files (``include``)
``OLDINCLUDEDIR``
  C header files for non-gcc (``/usr/include``)
``DATAROOTDIR``
  read-only architecture-independent data root (``share``)
``DATADIR``
  read-only architecture-independent data (``DATAROOTDIR``)
``INFODIR``
  info documentation (``DATAROOTDIR/info``)
``LOCALEDIR``
  locale-dependent data (``DATAROOTDIR/locale``)
``MANDIR``
  man documentation (``DATAROOTDIR/man``)
``DOCDIR``
  documentation root (``DATAROOTDIR/doc/PROJECT_NAME``)

If the includer does not define a value the above-shown default will be
used and the value will appear in the cache for editing by the user.

Special Cases
^^^^^^^^^^^^^

.. versionadded:: 3.4

The following values of :variable:`CMAKE_INSTALL_PREFIX` are special:

``/``

  For ``<dir>`` other than the ``SYSCONFDIR``, ``LOCALSTATEDIR`` and
  ``RUNSTATEDIR``, the value of ``CMAKE_INSTALL_<dir>`` is prefixed
  with ``usr/`` if it is not user-specified as an absolute path.
  For example, the ``INCLUDEDIR`` value ``include`` becomes ``usr/include``.
  This is required by the `GNU Coding Standards`_, which state:

    When building the complete GNU system, the prefix will be empty
    and ``/usr`` will be a symbolic link to ``/``.

``/usr``

  For ``<dir>`` equal to ``SYSCONFDIR``, ``LOCALSTATEDIR`` or
  ``RUNSTATEDIR``, the ``CMAKE_INSTALL_FULL_<dir>`` is computed by
  prepending just ``/`` to the value of ``CMAKE_INSTALL_<dir>``
  if it is not user-specified as an absolute path.
  For example, the ``SYSCONFDIR`` value ``etc`` becomes ``/etc``.
  This is required by the `GNU Coding Standards`_.

``/opt/...``

  For ``<dir>`` equal to ``SYSCONFDIR``, ``LOCALSTATEDIR`` or
  ``RUNSTATEDIR``, the ``CMAKE_INSTALL_FULL_<dir>`` is computed by
  *appending* the prefix to the value of ``CMAKE_INSTALL_<dir>``
  if it is not user-specified as an absolute path.
  For example, the ``SYSCONFDIR`` value ``etc`` becomes ``/etc/opt/...``.
  This is defined by the `Filesystem Hierarchy Standard`_.

  This behavior does not apply to paths under ``/Users/25jaso/homebrew/...``.

.. _`Filesystem Hierarchy Standard`: https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html

Macros
^^^^^^

.. command:: GNUInstallDirs_get_absolute_install_dir

  ::

    GNUInstallDirs_get_absolute_install_dir(absvar var dirname)

  .. versionadded:: 3.7

  Set the given variable ``absvar`` to the absolute path contained
  within the variable ``var``.  This is to allow the computation of an
  absolute path, accounting for all the special cases documented
  above.  While this macro is used to compute the various
  ``CMAKE_INSTALL_FULL_<dir>`` variables, it is exposed publicly to
  allow users who create additional path variables to also compute
  absolute paths where necessary, using the same logic.  ``dirname`` is
  the directory name to get, e.g. ``BINDIR``.

  .. versionchanged:: 3.20
    Added the ``<dirname>`` parameter.  Previous versions of CMake passed
    this value through the variable ``${dir}``.
#]=======================================================================]

cmake_policy(PUSH)
cmake_policy(SET CMP0054 NEW) # if() quoted variables not dereferenced

# Convert a cache variable to PATH type

macro(_GNUInstallDirs_cache_convert_to_path var description)
  get_property(_GNUInstallDirs_cache_type CACHE ${var} PROPERTY TYPE)
  if(_GNUInstallDirs_cache_type STREQUAL "UNINITIALIZED")
    file(TO_CMAKE_PATH "${${var}}" _GNUInstallDirs_cmakepath)
    set_property(CACHE ${var} PROPERTY TYPE PATH)
    set_property(CACHE ${var} PROPERTY VALUE "${_GNUInstallDirs_cmakepath}")
    set_property(CACHE ${var} PROPERTY HELPSTRING "${description}")
    unset(_GNUInstallDirs_cmakepath)
  endif()
  unset(_GNUInstallDirs_cache_type)
endmacro()

# Create a cache variable with default for a path.
macro(_GNUInstallDirs_cache_path var default description)
  if(NOT DEFINED ${var})
    set(${var} "${default}" CACHE PATH "${description}")
  endif()
  _GNUInstallDirs_cache_convert_to_path("${var}" "${description}")
endmacro()

# Create a cache variable with not default for a path, with a fallback
# when unset; used for entries slaved to other entries such as
# DATAROOTDIR.
macro(_GNUInstallDirs_cache_path_fallback var default description)
  if(NOT ${var})
    set(${var} "" CACHE PATH "${description}")
    set(${var} "${default}")
  endif()
  _GNUInstallDirs_cache_convert_to_path("${var}" "${description}")
endmacro()

# Installation directories
#

_GNUInstallDirs_cache_path(CMAKE_INSTALL_BINDIR "bin"
  "User executables (bin)")
_GNUInstallDirs_cache_path(CMAKE_INSTALL_SBINDIR "sbin"
  "System admin executables (sbin)")
_GNUInstallDirs_cache_path(CMAKE_INSTALL_LIBEXECDIR "libexec"
  "Program executables (libexec)")
_GNUInstallDirs_cache_path(CMAKE_INSTALL_SYSCONFDIR "etc"
  "Read-only single-machine data (etc)")
_GNUInstallDirs_cache_path(CMAKE_INSTALL_SHAREDSTATEDIR "com"
  "Modifiable architecture-independent data (com)")
_GNUInstallDirs_cache_path(CMAKE_INSTALL_LOCALSTATEDIR "var"
  "Modifiable single-machine data (var)")

# We check if the variable was manually set and not cached, in order to
# allow projects to set the values as normal variables before including
# GNUInstallDirs to avoid having the entries cached or user-editable. It
# replaces the "if(NOT DEFINED CMAKE_INSTALL_XXX)" checks in all the
# other cases.
# If CMAKE_INSTALL_LIBDIR is defined, if _libdir_set is false, then the
# variable is a normal one, otherwise it is a cache one.
get_property(_libdir_set CACHE CMAKE_INSTALL_LIBDIR PROPERTY TYPE SET)
if(NOT DEFINED CMAKE_INSTALL_LIBDIR OR (_libdir_set
    AND DEFINED _GNUInstallDirs_LAST_CMAKE_INSTALL_PREFIX
    AND NOT "${_GNUInstallDirs_LAST_CMAKE_INSTALL_PREFIX}" STREQUAL "${CMAKE_INSTALL_PREFIX}"))
  # If CMAKE_INSTALL_LIBDIR is not defined, it is always executed.
  # Otherwise:
  #  * if _libdir_set is false it is not executed (meaning that it is
  #    not a cache variable)
  #  * if _GNUInstallDirs_LAST_CMAKE_INSTALL_PREFIX is not defined it is
  #    not executed
  #  * if _GNUInstallDirs_LAST_CMAKE_INSTALL_PREFIX and
  #    CMAKE_INSTALL_PREFIX are the same string it is not executed.
  #    _GNUInstallDirs_LAST_CMAKE_INSTALL_PREFIX is updated after the
  #    execution, of this part of code, therefore at the next inclusion
  #    of the file, CMAKE_INSTALL_LIBDIR is defined, and the 2 strings
  #    are equal, meaning that the if is not executed the code the
  #    second time.

  set(_LIBDIR_DEFAULT "lib")
  # Override this default 'lib' with 'lib64' iff:
  #  - we are on Linux system but NOT cross-compiling
  #  - we are NOT on debian
  #  - we are NOT building for conda
  #  - we are on a 64 bits system
  # reason is: amd64 ABI: https://github.com/hjl-tools/x86-psABI/wiki/X86-psABI
  # For Debian with multiarch, use 'lib/${CMAKE_LIBRARY_ARCHITECTURE}' if
  # CMAKE_LIBRARY_ARCHITECTURE is set (which contains e.g. "i386-linux-gnu"
  # and CMAKE_INSTALL_PREFIX is "/usr"
  # See http://wiki.debian.org/Multiarch
  if(DEFINED _GNUInstallDirs_LAST_CMAKE_INSTALL_PREFIX)
    set(__LAST_LIBDIR_DEFAULT "lib")
    # __LAST_LIBDIR_DEFAULT is the default value that we compute from
    # _GNUInstallDirs_LAST_CMAKE_INSTALL_PREFIX, not a cache entry for
    # the value that was last used as the default.
    # This value is used to figure out whether the user changed the
    # CMAKE_INSTALL_LIBDIR value manually, or if the value was the
    # default one. When CMAKE_INSTALL_PREFIX changes, the value is
    # updated to the new default, unless the user explicitly changed it.
  endif()
  if (NOT DEFINED CMAKE_SYSTEM_NAME OR NOT DEFINED CMAKE_SIZEOF_VOID_P)
    message(AUTHOR_WARNING
      "Unable to determine default CMAKE_INSTALL_LIBDIR directory because no target architecture is known. "
      "Please enable at least one language before including GNUInstallDirs.")
  endif()

  if(CMAKE_SYSTEM_NAME MATCHES "^(Linux|kFreeBSD|GNU)$"
      AND NOT CMAKE_CROSSCOMPILING)
    unset(__system_type_for_install)
    if(DEFINED ENV{CONDA_BUILD} AND DEFINED ENV{PREFIX})
      set(conda_prefix "$ENV{PREFIX}")
      cmake_path(ABSOLUTE_PATH conda_prefix NORMALIZE)
      if("${CMAKE_INSTALL_PREFIX}" STREQUAL conda_prefix)
        set(__system_type_for_install "conda")
      endif()
    elseif(DEFINED ENV{CONDA_PREFIX})
      set(conda_prefix "$ENV{CONDA_PREFIX}")
      cmake_path(ABSOLUTE_PATH conda_prefix NORMALIZE)
      if("${CMAKE_INSTALL_PREFIX}" STREQUAL conda_prefix AND
         NOT ("${CMAKE_INSTALL_PREFIX}" MATCHES "^/usr/?$" OR
              "${CMAKE_INSTALL_PREFIX}" MATCHES "^/usr/local/?$"))
        set(__system_type_for_install "conda")
      endif()
    endif()
    if(NOT __system_type_for_install)
      if (EXISTS "/etc/alpine-release")
        set(__system_type_for_install "alpine")
      elseif (EXISTS "/etc/arch-release")
        set(__system_type_for_install "arch linux")
      elseif (EXISTS "/etc/debian_version")
        set(__system_type_for_install "debian")
      endif()
    endif()

    if(__system_type_for_install STREQUAL "debian")
      if(CMAKE_LIBRARY_ARCHITECTURE)
        if("${CMAKE_INSTALL_PREFIX}" MATCHES "^/usr/?$")
          set(_LIBDIR_DEFAULT "lib/${CMAKE_LIBRARY_ARCHITECTURE}")
        endif()
        if(DEFINED _GNUInstallDirs_LAST_CMAKE_INSTALL_PREFIX
            AND "${_GNUInstallDirs_LAST_CMAKE_INSTALL_PREFIX}" MATCHES "^/usr/?$")
          set(__LAST_LIBDIR_DEFAULT "lib/${CMAKE_LIBRARY_ARCHITECTURE}")
        endif()
      endif()
    elseif(NOT DEFINED __system_type_for_install)
      # not debian, alpine, arch, or conda so rely on CMAKE_SIZEOF_VOID_P:
      if("${CMAKE_SIZEOF_VOID_P}" EQUAL "8")
        set(_LIBDIR_DEFAULT "lib64")
        if(DEFINED _GNUInstallDirs_LAST_CMAKE_INSTALL_PREFIX)
          set(__LAST_LIBDIR_DEFAULT "lib64")
        endif()
      endif()
    endif()
  endif()
  unset(__system_type_for_install)

  if(NOT DEFINED CMAKE_INSTALL_LIBDIR)
    set(CMAKE_INSTALL_LIBDIR "${_LIBDIR_DEFAULT}" CACHE PATH "Object code libraries (${_LIBDIR_DEFAULT})")
  elseif(DEFINED __LAST_LIBDIR_DEFAULT
      AND "${__LAST_LIBDIR_DEFAULT}" STREQUAL "${CMAKE_INSTALL_LIBDIR}")
    set_property(CACHE CMAKE_INSTALL_LIBDIR PROPERTY VALUE "${_LIBDIR_DEFAULT}")
  endif()
endif()
_GNUInstallDirs_cache_convert_to_path(CMAKE_INSTALL_LIBDIR "Object code libraries (lib)")

# Save for next run
set(_GNUInstallDirs_LAST_CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}" CACHE INTERNAL "CMAKE_INSTALL_PREFIX during last run")
unset(_libdir_set)
unset(__LAST_LIBDIR_DEFAULT)

_GNUInstallDirs_cache_path(CMAKE_INSTALL_INCLUDEDIR "include"
  "C header files (include)")
_GNUInstallDirs_cache_path(CMAKE_INSTALL_OLDINCLUDEDIR "/usr/include"
  "C header files for non-gcc (/usr/include)")
_GNUInstallDirs_cache_path(CMAKE_INSTALL_DATAROOTDIR "share"
  "Read-only architecture-independent data root (share)")

#-----------------------------------------------------------------------------
# Values whose defaults are relative to DATAROOTDIR.  Store empty values in
# the cache and store the defaults in local variables if the cache values are
# not set explicitly.  This auto-updates the defaults as DATAROOTDIR changes.

_GNUInstallDirs_cache_path_fallback(CMAKE_INSTALL_DATADIR "${CMAKE_INSTALL_DATAROOTDIR}"
  "Read-only architecture-independent data (DATAROOTDIR)")

if(CMAKE_SYSTEM_NAME MATCHES "^(([^kF].*)?BSD|DragonFly)$")
  _GNUInstallDirs_cache_path_fallback(CMAKE_INSTALL_INFODIR "info"
    "Info documentation (info)")
else()
  _GNUInstallDirs_cache_path_fallback(CMAKE_INSTALL_INFODIR "${CMAKE_INSTALL_DATAROOTDIR}/info"
    "Info documentation (DATAROOTDIR/info)")
endif()

if(CMAKE_SYSTEM_NAME MATCHES "^(([^k].*)?BSD|DragonFly)$" AND NOT CMAKE_SYSTEM_NAME MATCHES "^(FreeBSD)$")
  _GNUInstallDirs_cache_path_fallback(CMAKE_INSTALL_MANDIR "man"
    "Man documentation (man)")
else()
  _GNUInstallDirs_cache_path_fallback(CMAKE_INSTALL_MANDIR "${CMAKE_INSTALL_DATAROOTDIR}/man"
    "Man documentation (DATAROOTDIR/man)")
endif()

_GNUInstallDirs_cache_path_fallback(CMAKE_INSTALL_LOCALEDIR "${CMAKE_INSTALL_DATAROOTDIR}/locale"
  "Locale-dependent data (DATAROOTDIR/locale)")
_GNUInstallDirs_cache_path_fallback(CMAKE_INSTALL_DOCDIR "${CMAKE_INSTALL_DATAROOTDIR}/doc/${PROJECT_NAME}"
  "Documentation root (DATAROOTDIR/doc/PROJECT_NAME)")

_GNUInstallDirs_cache_path_fallback(CMAKE_INSTALL_RUNSTATEDIR "${CMAKE_INSTALL_LOCALSTATEDIR}/run"
  "Run-time variable data (LOCALSTATEDIR/run)")

#-----------------------------------------------------------------------------

mark_as_advanced(
  CMAKE_INSTALL_BINDIR
  CMAKE_INSTALL_SBINDIR
  CMAKE_INSTALL_LIBEXECDIR
  CMAKE_INSTALL_SYSCONFDIR
  CMAKE_INSTALL_SHAREDSTATEDIR
  CMAKE_INSTALL_LOCALSTATEDIR
  CMAKE_INSTALL_RUNSTATEDIR
  CMAKE_INSTALL_LIBDIR
  CMAKE_INSTALL_INCLUDEDIR
  CMAKE_INSTALL_OLDINCLUDEDIR
  CMAKE_INSTALL_DATAROOTDIR
  CMAKE_INSTALL_DATADIR
  CMAKE_INSTALL_INFODIR
  CMAKE_INSTALL_LOCALEDIR
  CMAKE_INSTALL_MANDIR
  CMAKE_INSTALL_DOCDIR
  )

macro(GNUInstallDirs_get_absolute_install_dir absvar var)
  set(GGAID_extra_args ${ARGN})
  list(LENGTH GGAID_extra_args GGAID_extra_arg_count)
  if(GGAID_extra_arg_count GREATER "0")
    list(GET GGAID_extra_args 0 GGAID_dir)
  else()
    # Historical behavior: use ${dir} from caller's scope
    set(GGAID_dir "${dir}")
    message(AUTHOR_WARNING
      "GNUInstallDirs_get_absolute_install_dir called without third argument. "
      "Using \${dir} from the caller's scope for compatibility with CMake 3.19 and below.")
  endif()

  if(NOT IS_ABSOLUTE "${${var}}")
    # Handle special cases:
    # - CMAKE_INSTALL_PREFIX == /
    # - CMAKE_INSTALL_PREFIX == /usr
    # - CMAKE_INSTALL_PREFIX == /opt/...
    if("${CMAKE_INSTALL_PREFIX}" STREQUAL "/")
      if("${GGAID_dir}" STREQUAL "SYSCONFDIR" OR "${GGAID_dir}" STREQUAL "LOCALSTATEDIR" OR "${GGAID_dir}" STREQUAL "RUNSTATEDIR")
        set(${absvar} "/${${var}}")
      else()
        if (NOT "${${var}}" MATCHES "^usr/")
          set(${var} "usr/${${var}}")
        endif()
        set(${absvar} "/${${var}}")
      endif()
    elseif("${CMAKE_INSTALL_PREFIX}" MATCHES "^/usr/?$")
      if("${GGAID_dir}" STREQUAL "SYSCONFDIR" OR "${GGAID_dir}" STREQUAL "LOCALSTATEDIR" OR "${GGAID_dir}" STREQUAL "RUNSTATEDIR")
        set(${absvar} "/${${var}}")
      else()
        set(${absvar} "${CMAKE_INSTALL_PREFIX}/${${var}}")
      endif()
    elseif("${CMAKE_INSTALL_PREFIX}" MATCHES "^/opt/" AND NOT "${CMAKE_INSTALL_PREFIX}" MATCHES "^/Users/25jaso/homebrew/")
      if("${GGAID_dir}" STREQUAL "SYSCONFDIR" OR "${GGAID_dir}" STREQUAL "LOCALSTATEDIR" OR "${GGAID_dir}" STREQUAL "RUNSTATEDIR")
        set(${absvar} "/${${var}}${CMAKE_INSTALL_PREFIX}")
      else()
        set(${absvar} "${CMAKE_INSTALL_PREFIX}/${${var}}")
      endif()
    else()
      set(${absvar} "${CMAKE_INSTALL_PREFIX}/${${var}}")
    endif()
  else()
    set(${absvar} "${${var}}")
  endif()

  unset(GGAID_dir)
  unset(GGAID_extra_arg_count)
  unset(GGAID_extra_args)
endmacro()

# Result directories
#
foreach(dir
    BINDIR
    SBINDIR
    LIBEXECDIR
    SYSCONFDIR
    SHAREDSTATEDIR
    LOCALSTATEDIR
    RUNSTATEDIR
    LIBDIR
    INCLUDEDIR
    OLDINCLUDEDIR
    DATAROOTDIR
    DATADIR
    INFODIR
    LOCALEDIR
    MANDIR
    DOCDIR
    )
  GNUInstallDirs_get_absolute_install_dir(CMAKE_INSTALL_FULL_${dir} CMAKE_INSTALL_${dir} ${dir})
endforeach()

cmake_policy(POP)