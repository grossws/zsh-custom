# docker aliases

alias zshconfig='vim ~/.zshrc'

alias dk='docker'

alias dks='docker ps'
alias dksa='docker ps -a'
alias dkd='docker rm -v'

function dki() {
  if [ $# -gt 0 ] ; then
    docker images | grep "$@"
  else
    docker images
  fi
}

alias dkdi='docker rmi'

alias dkr='docker run -it'
alias dkrv='docker run -it --rm'
alias dkrd='docker run -d'
alias dke='docker exec -it'

alias dkb='docker build -t'

alias dkl='docker logs'
alias dklt='docker logs --tail'
alias dklf='docker logs -f --tail 20'

function dkit() {
  echo -e "GET /images/json?all=1 HTTP/1.0\r\n" | nc -U /var/run/docker.sock | tail -n +5 | $HOME/bin/dockviz images --tree
}

function dkct() {
  echo -e "GET /containers/json?all=1 HTTP/1.0\r\n" | nc -U /var/run/docker.sock | tail -n +5 | $HOME/bin/dockviz containers --tree
}

alias dkc='docker-compose'


# git aliases

alias tiga='tig --all'
alias qg='qgit'
alias qga='qgit --all'

alias gl-list='ssh gl info'

alias gmf='git merge --no-ff'

alias grbom='git rebase origin/master'
alias grbum='git rebase upstream/master'
alias grbut='git rebase upstream/trunk'

alias gfo='git fetch origin'
alias gfu='git fetch upstream'


# maven customization

export M2_HOME=/opt/maven

function mvn-help() {
  if [[ $# -lt 1 ]] ; then
    echo "usage: mvn-help plugin:goal"
    return 1
  fi

  mvn help:describe -Dcmd="$1" -Ddetail
}

alias mvnprerel='mvn -Prelease-profile clean install'

function mvnrp() {
  local rel
  local dev
  local answer

  echo "usage: mvnrp [release [development]]"
  if [ $# -lt 1 ] ; then
    rel=$(echo 'VERSION=${project.version}' | mvn -o help:evaluate | grep '^VERSION=' | sed 's/^VERSION=//; s/-SNAPSHOT$//;')
  else
    rel=$1
  fi

  # append patch version for release versions lacking it
  if [ -z "$(semver $rel)" ] ; then
    rel=${rel}.0
  fi

  if [ $# -lt 2 ] ; then
    dev=$(semver -i $rel)
  else
    dev=${2%-SNAPSHOT}
  fi

  CMD="mvn release:prepare -Dtag=v$rel -DreleaseVersion=$rel -DdevelopmentVersion=${dev}-SNAPSHOT"
  echo -n "execute \"$CMD\"? [y/N] "

  read -r answer
  if [ "x$answer" = "xy" ] ; then
    eval "$CMD"
    git fetch
  else
    echo "do nothing"
  fi
}

function mvnrb() {
  if [ $# -ne 3 ] ; then
    echo "usage: mvnrp branch release development"
  else
    branch=$1
    rel=$2
    dev=${3%-SNAPSHOT}

    CMD="mvn release:branch -DbranchName=r$branch -Dtag=v$rel -DreleaseVersion=$rel -DdevelopmentVersion=${dev}-SNAPSHOT"
    echo -n "execute \"$CMD\"? [y/N] "

    read -r answer
    if [ "x$answer" = "xy" ] ; then
      eval "$CMD"
      git fetch
    else
      echo "do nothing"
    fi

    unset answer
  fi
}

alias mvnrel='mvn release:perform'

function mvn_download() {
  group=org.anenerbe
  artifact=
  packaging=jar
  classifier=
  version=RELEASE
  output=

  OPTIND=1
  while getopts "hg:a:v:c:p:o:" opt ; do
    case "$opt" in
      h)
        echo -ne "usage:\tmvn_download [-o <output-file>] [-g <groupId=org.anenerbe>] [-a <artifactId>] [-p <packaging=jar>] [-v <version=RELEASE>] [-c <classifier=>]\n\tmvn_download -h\n\nreturns 0 in case of success and not 0 otherwise\n\n"
        return 1
        ;;
      g)
        group=$OPTARG
        ;;
      a)
        artifact=$OPTARG
        ;;
      v)
        version=$OPTARG
        ;;
      c)
        classifier=$OPTARG
        ;;
      p)
        packaging=$OPTARG
        ;;
      o)
        output=$OPTARG
        ;;
    esac
  done

  shift $((OPTIND-1))

  [ "$1" = "--" ] && shift

  if [ $# -gt 0 ] ; then
    echo "Unrecognized extra args: $@"
    return 1
  fi

  if [ -z "$artifact" ] ; then
    echo "error: artifactId should be set"
    return 1
  fi

  mvn dependency:copy -Dartifact=${group}:${artifact}:${version}:${packaging}:${classifier} -Dmdep.stripVersion=true -Dmdep.overWriteReleases=true -Dmdep.overWriteSnapshots=true -DoutputDirectory=./ -Dsilent=true
  [[ -n "$output" && -n "$classifier" ]] && mv -vf ./${artifact}-${classifier}.${packaging} ${output}
  [[ -n "$output" && -z "$classifier" ]] && mv -vf ./${artifact}.${packaging} ${output}

  return $?
}


# systemctl

alias sc='systemctl'
alias sc-daemon-reload='sudo systemctl daemon-reload'


# journalctl

alias jc='journalctl'
alias jcu='journalctl -u'
alias jceu='journalctl -eu'
alias jcfu='journalctl -fu'

function jcd() {
  journalctl -u docker.service CONTAINER_NAME="$@"
}

function jcdf() {
  journalctl -fu docker.service CONTAINER_NAME="$@"
}


# firewalld

# temporary until fixed in gh:robbyrussell/oh-my-zsh
function fwl () {
  # converts output to zsh array ()
  # @f flag split on new line
  zones=("${(@f)$(sudo firewall-cmd --get-active-zones | grep -v 'interfaces\|sources')}")

  for i in $zones; do
    sudo firewall-cmd --zone $i --list-all
  done

  echo 'Direct Rules:'
  sudo firewall-cmd --direct --get-all-rules
}

function fwpl() {
  # converts output to zsh array ()
  # @f flag split on new line
  zones=("${(@f)$(sudo firewall-cmd --get-active-zones | grep -v 'interfaces\|sources')}")

  for i in $zones; do
    sudo firewall-cmd --permanent --zone $i --list-all
  done

  echo 'Direct Rules:'
  sudo firewall-cmd --permanent --direct --get-all-rules
}


# ansible

alias ans='ansible'

alias ansp='ansible-playbook'

alias ansg='ansible-galaxy'
alias ansgi='ansible-galaxy install'
alias ansgir='ansible-galaxy install --force --role-file requirements.yml'

function ansfc() {
  ANSIBLE_FACTS_CACHE=$HOME/.ansible/facts-cache
  echo "cleaning ansible facts cache ${ANSIBLE_FACTS_CACHE}"
  rm -rf ${ANSIBLE_FACTS_CACHE}
}


# sudo aliases

alias _='sudo'
alias _e='sudo -e'
alias _i='sudo -i'


# other

function passwd-read() {
  read -s -r pp\?'Enter password: '
  echo -n $pp
}

function mksrcinfo() {
  makepkg --printsrcinfo > .SRCINFO
}

alias rgi='rg -i'

alias rmqctl='sudo -u rabbitmq -i rabbitmqctl'

alias ssa="sudo ss --no-header --numeric --listening --tcp --udp --processes | awk '{ print \$1, \$5, \$7 }' | column -t -o \$'\\t\\t'"
alias sst="sudo ss --no-header --numeric --listening --tcp --processes | awk '{ print \$4, \$6 }' | column -t -o \$'\\t\\t'"
alias ssu="sudo ss --no-header --numeric --listening --udp --processes | awk '{ print \$4, \$6 }' | column -t -o \$'\\t\\t'"


# vim:sw=2:et:ai:sts=2:

