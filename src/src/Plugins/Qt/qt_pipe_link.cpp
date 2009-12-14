
/******************************************************************************
* MODULE     : qt_pipe_link.cpp
* DESCRIPTION: TeXmacs links by pipes
* COPYRIGHT  : (C) 2000  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#if defined (QTTEXMACS) && (defined (__MINGW__) || defined (__MINGW32__))

#include "tm_link.hpp"
#include "QTMPipeLink.hpp"
#include "hashset.hpp"
#include "iterator.hpp"
#include "timer.hpp"

#include <sys/types.h>
#include <signal.h>
#if defined(__MINGW__) || defined(__MINGW32__)
#else
#  include <sys/wait.h>
#endif

hashset<pointer> pipe_link_set;

/******************************************************************************
* Definition of qt_pipe_link_rep class
******************************************************************************/

struct qt_pipe_link_rep: tm_link_rep {
  QTMPipeLink PipeLink;

public:
  qt_pipe_link_rep (string cmd);
  ~qt_pipe_link_rep ();

  string  start ();
  void    write (string s, int channel);
  string& watch (int channel);
  string  read (int channel);
  void    listen (int msecs);
  bool    is_readable (int channel);
  void    interrupt ();
  void    stop ();
  void    feed (int channel);
};

qt_pipe_link_rep::qt_pipe_link_rep (string cmd) : PipeLink (cmd) {
  PipeLink.feed_cmd = &feed_cmd;
  pipe_link_set->insert ((pointer) this);
  alive = false;
}

qt_pipe_link_rep::~qt_pipe_link_rep () {
  stop ();
  pipe_link_set->remove ((pointer) this);
}

/******************************************************************************
* Routines for qt_pipe_links
******************************************************************************/

string
qt_pipe_link_rep::start () {
  if (alive) return "busy";
  if (DEBUG_AUTO) cerr << "TeXmacs] Launching '" << PipeLink.cmd << "'\n";
  if (! PipeLink.launchCmd ()) {
    if (DEBUG_AUTO) cerr << "TeXmacs] Error: cannot start '" << PipeLink.cmd << "'\n";
    return "Error: cannot start application";
  }
  alive= true;
  return "ok";
}

void
qt_pipe_link_rep::write (string s, int channel) {
  if ((!alive) || (channel != LINK_IN)) return;
  if (-1 == PipeLink.writeStdin (s)) {
    cerr << "TeXmacs] Error: cannot write to '" << PipeLink.cmd << "'\n";
    PipeLink.killProcess ();
  }
}

void
qt_pipe_link_rep::feed (int channel) {
  if ((!alive) || ((channel != LINK_OUT) && (channel != LINK_ERR))) return;
  if (channel == LINK_OUT) PipeLink.feedBuf (QProcess::StandardOutput);
  else PipeLink.feedBuf (QProcess::StandardError);
}

string&
qt_pipe_link_rep::watch (int channel) {
  static string empty_string= "";
  if (channel == LINK_OUT) return PipeLink.getOutbuf ();
  else if (channel == LINK_ERR) return PipeLink.getErrbuf ();
  else  return empty_string;
}

string
qt_pipe_link_rep::read (int channel) {
  if (channel == LINK_OUT) {
    string r= PipeLink.getOutbuf ();
    PipeLink.setOutbuf ("");
    return r;
  }
  else if (channel == LINK_ERR) {
    string r= PipeLink.getErrbuf ();
    PipeLink.setErrbuf ("");
    return r;
  }
  else return string("");
}

void
qt_pipe_link_rep::listen (int msecs) {
  if (!alive) return;
  time_t wait_until= texmacs_time () + msecs;
  while ((PipeLink.getOutbuf() == "") && (PipeLink.getErrbuf() == "")) {
    PipeLink.listenChannel (QProcess::StandardOutput, 0);
    PipeLink.listenChannel (QProcess::StandardError, 0);
    if (texmacs_time () - wait_until > 0) break;
  }
}

bool
qt_pipe_link_rep::is_readable (int channel) {
  if ((!alive) || ((channel != LINK_OUT) && (channel != LINK_ERR))) return false;
  if (channel == LINK_OUT) PipeLink.listenChannel (QProcess::StandardOutput, 0);
  else PipeLink.listenChannel (QProcess::StandardError, 0);
}

void
qt_pipe_link_rep::interrupt () {
  if (!alive) return;
#if defined(__MINGW__) || defined(__MINGW32__)
  // Not implemented
#else
  ::killpg(PipeLink.pid (), SIGINT);
#endif
}

void
qt_pipe_link_rep::stop () {
  PipeLink.killProcess ();
  alive= false;
}

/******************************************************************************
* Main builder function for qt_pipe_links
******************************************************************************/

tm_link
make_pipe_link (string cmd) {
  return tm_new<qt_pipe_link_rep> (cmd);
}

/******************************************************************************
* Emergency exit for all pipes
******************************************************************************/

void
close_all_pipes () {
  iterator<pointer> it= iterate (pipe_link_set);
  while (it->busy()) {
    qt_pipe_link_rep* con= (qt_pipe_link_rep*) it->next();
    if (con->alive) con->stop ();
  }
}

#endif // defined (QTTEXMACS) && (defined (__MINGW__) || defined (__MINGW32__))
