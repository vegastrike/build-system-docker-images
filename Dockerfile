# Dockerfile
#
# Copyright (C) 2020-2022 Stephen G. Tuggy and other Vega Strike contributors
#
# This file is part of Vega Strike.
#
# Vega Strike is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Vega Strike is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Vega Strike.  If not, see <https://www.gnu.org/licenses/>.

ARG  from
FROM ${from}

WORKDIR /usr/src/build-system-docker-images

COPY script/ script/

RUN DEBIAN_FRONTEND=noninteractive script/bootstrap 1
