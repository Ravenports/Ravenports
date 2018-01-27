# This script produces grouplist argument for usermod -G on solaris
# That means the secondary user groups (excludes the primary group)
# Feed in output of "id -a <user>"
#
# sample output:
# uid=0(root) gid=0(root) groups=0(root),1(other),2(bin),3(sys),4(adm),5(uucp),6(mail),7(tty),8(lp),9(nuucp),12(daemon)
#
# input: newgroup
#
# This script is unused -- it was transcribed to do-users-group.sh
#

BEGIN {FS="="; seen=0}
{ 
  n=split($4,ray,"(");
  g=0;
  for (x=2; x<=n; x++) {
    j=split(ray[x], tray, ")");
    if (tray[1] == newgroup) { seen=1 };
    g++;
    answer[g] = tray[1];
  };
  if (!seen && newgroup != "") { g++; answer[g] = newgroup };
}
END {
   result=answer[1];
   for (x=2; x<=g; x++) {
     result = result "," answer[x];
   }
   printf ("%s\n", result);
}
