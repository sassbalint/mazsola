#!/usr/bin/perl -w

use strict;

my $F = '';

while (<>) {
if ( /^m/ ) { # f�szint
  if ( /^meg/ ) { # ptn-szint
    if ( /^meg[a�bcde]/ ) { # ptn-szint
      $F = 'm_eg_a�bcde.betu';
    } elsif ( /^meg[�fghi�j]/ ) { # ptn-szint
      $F = 'm_eg_�fghi�j.betu';
    } elsif ( /^meg[klmn]/ ) { # ptn-szint
      $F = 'm_eg_klmn.betu';
    } elsif ( /^meg[o���pqrs]/ ) { # ptn-szint
      $F = 'm_eg_o���pqrs.betu';
    } else {
      $F = 'm_eg_x.betu';
    }
  } else {
    if ( /^mo/ ) { # ptn-szint
      $F = 'm_x_o.betu';
    } else {
      $F = 'm_x_x.betu';
    }
  }
}

if ( /^v/ ) { # f�szint
  if ( /^van/ ) { # ptn-szint
    $F = 'v_an.betu';
  } else {
    if ( /^v[e]/ ) { # ptn-szint
      $F = 'v_x_e.betu';
    } elsif ( /^v[��]/ ) { # ptn-szint
      $F = 'v_x_��.betu';
    } else {
      $F = 'v_x_x.betu';
    }
  }
}

if ( /^k/ ) { # f�szint
  if ( /^ki/ ) { # ptn-szint
    if ( /^ki[eatlnskziro�m]/ ) { # ptn-szint
      $F = 'k_i_eatlnskziro�m.betu';
    } else {
      $F = 'k_i_x.betu';
    }
  } else {
    if ( /^k[e]/ ) { # ptn-szint
      $F = 'k_x_e.betu';
    } elsif ( /^k[a��]/ ) { # ptn-szint
      $F = 'k_x_a��.betu';
    } else {
      $F = 'k_x_x.betu';
    }
  }
}

if ( /^e/ ) { # f�szint
  if ( /^el/ ) { # ptn-szint
    if ( /^el[eatlnskz]/ ) { # ptn-szint
      $F = 'e_l_eatlnskz.betu';
    } elsif ( /^el[iro�m�gb]/ ) { # ptn-szint
      $F = 'e_l_iro�m�gb.betu';
    } elsif ( /^el[�v]/ ) { # ptn-szint
      $F = 'e_l_�v.betu';
    } else {
      $F = 'e_l_x.betu';
    }
  } else {
    $F = 'e_x.betu';
  }
}

if ( /^t/ ) { # f�szint
  if ( /^t[a]/ ) { # ptn-szint
    $F = 't_a.betu';
  } elsif ( /^t[e]/ ) { # ptn-szint
    $F = 't_e.betu';
  } elsif ( /^t[��i�]/ ) { # ptn-szint
    $F = 't_��i�.betu';
  } else {
    $F = 't_x.betu';
  }
}

if ( /^l/ ) { # f�szint
  if ( /^le/ ) { # ptn-szint
    if ( /^lesz/ ) { # ptn-szint
      $F = 'l_e_sz.betu';
    } else {
      $F = 'l_e_x.betu';
    }
  } else {
    $F = 'l_x.betu';
  }
}

if ( /^f/ ) { # f�szint
  if ( /^fel/ ) { # ptn-szint
    $F = 'f_el.betu';
  } else {
    if ( /^fo/ ) { # ptn-szint
      $F = 'f_x_o.betu';
    } else {
      $F = 'f_x_x.betu';
    }
  }
}

if ( /^b/ ) { # f�szint
  if ( /^be/ ) { # ptn-szint
    if ( /^be[eatlnskz]/ ) { # ptn-szint
      $F = 'b_e_eatlnskz.betu';
    } else {
      $F = 'b_e_x.betu';
    }
  } else {
    $F = 'b_x.betu';
  }
}

if ( /^s/ ) { # f�szint
  if ( /^sz/ ) { # ptn-szint
    if ( /^sz[ae��]/ ) { # ptn-szint
      $F = 's_z_ae��.betu';
    } else {
      $F = 's_z_x.betu';
    }
  } else {
    $F = 's_x.betu';
  }
}

if ( /^h/ ) { # f�szint
  if ( /^h[ae��]/ ) { # ptn-szint
    $F = 'h_ae��.betu';
  } else {
    $F = 'h_x.betu';
  }
}

# v�g�l a sima sz�tbontatlan bet�k feldolgoz�sa j�n
if ( $F eq '' ) {
  /^(.)/;
  $F = "$1.betu";
}

print "$F\n";
}
