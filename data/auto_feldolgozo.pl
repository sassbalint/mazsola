#!/usr/bin/perl -w

use strict;

my $F = '';

while (<>) {
if ( /^m/ ) { # fõszint
  if ( /^meg/ ) { # ptn-szint
    if ( /^meg[aábcde]/ ) { # ptn-szint
      $F = 'm_eg_aábcde.betu';
    } elsif ( /^meg[éfghiíj]/ ) { # ptn-szint
      $F = 'm_eg_éfghiíj.betu';
    } elsif ( /^meg[klmn]/ ) { # ptn-szint
      $F = 'm_eg_klmn.betu';
    } elsif ( /^meg[oóöõpqrs]/ ) { # ptn-szint
      $F = 'm_eg_oóöõpqrs.betu';
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

if ( /^v/ ) { # fõszint
  if ( /^van/ ) { # ptn-szint
    $F = 'v_an.betu';
  } else {
    if ( /^v[e]/ ) { # ptn-szint
      $F = 'v_x_e.betu';
    } elsif ( /^v[áé]/ ) { # ptn-szint
      $F = 'v_x_áé.betu';
    } else {
      $F = 'v_x_x.betu';
    }
  }
}

if ( /^k/ ) { # fõszint
  if ( /^ki/ ) { # ptn-szint
    if ( /^ki[eatlnskziroám]/ ) { # ptn-szint
      $F = 'k_i_eatlnskziroám.betu';
    } else {
      $F = 'k_i_x.betu';
    }
  } else {
    if ( /^k[e]/ ) { # ptn-szint
      $F = 'k_x_e.betu';
    } elsif ( /^k[aáé]/ ) { # ptn-szint
      $F = 'k_x_aáé.betu';
    } else {
      $F = 'k_x_x.betu';
    }
  }
}

if ( /^e/ ) { # fõszint
  if ( /^el/ ) { # ptn-szint
    if ( /^el[eatlnskz]/ ) { # ptn-szint
      $F = 'e_l_eatlnskz.betu';
    } elsif ( /^el[iroámégb]/ ) { # ptn-szint
      $F = 'e_l_iroámégb.betu';
    } elsif ( /^el[õv]/ ) { # ptn-szint
      $F = 'e_l_õv.betu';
    } else {
      $F = 'e_l_x.betu';
    }
  } else {
    $F = 'e_x.betu';
  }
}

if ( /^t/ ) { # fõszint
  if ( /^t[a]/ ) { # ptn-szint
    $F = 't_a.betu';
  } elsif ( /^t[e]/ ) { # ptn-szint
    $F = 't_e.betu';
  } elsif ( /^t[áéií]/ ) { # ptn-szint
    $F = 't_áéií.betu';
  } else {
    $F = 't_x.betu';
  }
}

if ( /^l/ ) { # fõszint
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

if ( /^f/ ) { # fõszint
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

if ( /^b/ ) { # fõszint
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

if ( /^s/ ) { # fõszint
  if ( /^sz/ ) { # ptn-szint
    if ( /^sz[aeáé]/ ) { # ptn-szint
      $F = 's_z_aeáé.betu';
    } else {
      $F = 's_z_x.betu';
    }
  } else {
    $F = 's_x.betu';
  }
}

if ( /^h/ ) { # fõszint
  if ( /^h[aeáé]/ ) { # ptn-szint
    $F = 'h_aeáé.betu';
  } else {
    $F = 'h_x.betu';
  }
}

# végül a sima szétbontatlan betûk feldolgozása jön
if ( $F eq '' ) {
  /^(.)/;
  $F = "$1.betu";
}

print "$F\n";
}
