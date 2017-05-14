# docker aliases

alias dk='docker'

alias dks='docker ps'
alias dksa='docker ps -a'
alias dkd='docker rm -v'

dki() {
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
alias dke='docker exec'

alias dkb='docker build -t'

alias dkl='docker logs'

dkit() {
  echo -e "GET /images/json?all=1 HTTP/1.0\r\n" | nc -U /var/run/docker.sock | tail -n +5 | $HOME/bin/dockviz images --tree
}

dkct() {
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


mvnrp() {
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

mvnrb() {
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

mvn_download() {
  group=org.anenerbe
  artifact=
  packaging=jar
  classifier=
  version=RELEASE

  OPTIND=1
  while getopts "hg:a:v:c:p:" opt ; do
    case "$opt" in
      h)
        echo -ne "usage:\tmvn_download [-g <groupId=org.anenerbe>] [-a <artifactId>] [-p <packaging=jar>] [-v <version=RELEASE>] [-c <classifier=>]\n\tmvn_download -h\n\nreturns 0 in case of success and not 0 otherwise\n\n"
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

  mvn dependency:copy -Dartifact=${group}:${artifact}:${version}:${packaging}:${classifier} -Dmdep.stripVersion=true -Dmdep.overWriteReleases=true -Dmdep.overWriteSnapshots=true -DoutputDirectory=./
  return $?
}


# journalctl

alias jc='journalctl'
alias jcu='journalctl -u'
alias jceu='journalctl -eu'
alias jcfu='journalctl -fu'

jcd() {
  journalctl -u docker.service CONTAINER_NAME="$@"
}

jcdf() {
  journalctl -fu docker.service CONTAINER_NAME="$@"
}


# sudo aliases

alias _='sudo'
alias _e='sudo -e'
alias _i='sudo -i'


# other

passwd-read() {
  read -s -r pp\?'Enter password: '
  echo -n $pp
}


# vim:sw=2:et:ai:sts=2:

