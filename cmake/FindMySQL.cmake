#--------------------------------------------------------
# Copyright (c) 2007, 2011, Oracle and/or its affiliates. All rights reserved.
#
# The MySQL Connector/ODBC is licensed under the terms of the GPLv2
# <http://www.gnu.org/licenses/old-licenses/gpl-2.0.html>, like most
# MySQL Connectors. There are special exceptions to the terms and
# conditions of the GPLv2 as it is applied to this software, see the
# FLOSS License Exception
# <http://www.mysql.com/about/legal/licensing/foss-exception.html>.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published
# by the Free Software Foundation; version 2 of the License.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
# for more details.
# 
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA

##########################################################################


#-------------- FIND MYSQL_INCLUDE_DIR ------------------
FIND_PATH(MYSQL_INCLUDE_DIR mysql.h
		$ENV{MYSQL_INCLUDE_DIR}
		$ENV{MYSQL_DIR}/include
		/usr/include/mysql
		/usr/local/include/mysql
		/opt/mysql/mysql/include
		/opt/mysql/mysql/include/mysql
		/usr/local/mysql/include
		/usr/local/mysql/include/mysql
		$ENV{ProgramFiles}/MySQL/*/include
		$ENV{SystemDrive}/MySQL/*/include)

#----------------- FIND MYSQL_LIB_DIR -------------------
IF (WIN32)
	# Set lib path suffixes
	# dist = for mysql binary distributions
	# build = for custom built tree
	IF (CMAKE_BUILD_TYPE STREQUAL Debug)
		SET(libsuffixDist debug)
		SET(libsuffixBuild Debug)
	ELSE (CMAKE_BUILD_TYPE STREQUAL Debug)
		SET(libsuffixDist opt)
		SET(libsuffixBuild Release)
		ADD_DEFINITIONS(-DDBUG_OFF)
	ENDIF (CMAKE_BUILD_TYPE STREQUAL Debug)

	FIND_LIBRARY(MYSQL_LIB NAMES mysqlclient
				 PATHS
				 $ENV{MYSQL_DIR}/lib/${libsuffixDist}
				 $ENV{MYSQL_DIR}/lib
				 $ENV{MYSQL_DIR}/libmysql
				 $ENV{MYSQL_DIR}/lib
				 $ENV{MYSQL_DIR}/libmysql/${libsuffixBuild}
				 $ENV{MYSQL_DIR}/client/${libsuffixBuild}
				 $ENV{MYSQL_DIR}/libmysql/${libsuffixBuild}
				 $ENV{ProgramFiles}/MySQL/*/lib/${libsuffixDist}
				 $ENV{ProgramFiles}/MySQL/*/lib
				 $ENV{SystemDrive}/MySQL/*/lib/${libsuffixDist})
ELSE (WIN32)
	FIND_LIBRARY(MYSQL_LIB NAMES mysqlclient_r
				 PATHS
				 $ENV{MYSQL_DIR}/libmysql_r/.libs
				 $ENV{MYSQL_DIR}/lib
				 $ENV{MYSQL_DIR}/lib/mysql
				 /usr/lib/mysql
				 /usr/local/lib/mysql
				 /usr/local/mysql/lib
				 /usr/local/mysql/lib/mysql
				 /opt/mysql/mysql/lib
				 /opt/mysql/mysql/lib/mysql)
ENDIF (WIN32)

IF(MYSQL_LIB)
	GET_FILENAME_COMPONENT(MYSQL_LIB_DIR ${MYSQL_LIB} PATH)
ENDIF(MYSQL_LIB)

IF (MYSQL_INCLUDE_DIR AND MYSQL_LIB_DIR)
	SET(MYSQL_FOUND TRUE)

	INCLUDE_DIRECTORIES(${MYSQL_INCLUDE_DIR})
	LINK_DIRECTORIES(${MYSQL_LIB_DIR})

	FIND_LIBRARY(MYSQL_ZLIB zlib PATHS ${MYSQL_LIB_DIR})
	FIND_LIBRARY(MYSQL_YASSL yassl PATHS ${MYSQL_LIB_DIR})
	FIND_LIBRARY(MYSQL_TAOCRYPT taocrypt PATHS ${MYSQL_LIB_DIR})
	IF (WIN32)
		SET(MYSQL_CLIENT_LIBS mysqlclient)
	ELSE (WIN32)
		SET(MYSQL_CLIENT_LIBS mysqlclient_r)
	ENDIF (WIN32)
	IF (MYSQL_ZLIB)
		SET(MYSQL_CLIENT_LIBS ${MYSQL_CLIENT_LIBS} zlib)
	ENDIF (MYSQL_ZLIB)
	IF (MYSQL_YASSL)
		SET(MYSQL_CLIENT_LIBS ${MYSQL_CLIENT_LIBS} yassl)
	ENDIF (MYSQL_YASSL)
	IF (MYSQL_TAOCRYPT)
		SET(MYSQL_CLIENT_LIBS ${MYSQL_CLIENT_LIBS} taocrypt)
	ENDIF (MYSQL_TAOCRYPT)
	IF (EXTRA_MYSQL_DEP)
		SET(MYSQL_CLIENT_LIBS ${MYSQL_CLIENT_LIBS} ${EXTRA_MYSQL_DEP})
	ENDIF (EXTRA_MYSQL_DEP)
	# Added needed mysqlclient dependencies on Windows
	IF (WIN32)
		SET(MYSQL_CLIENT_LIBS ${MYSQL_CLIENT_LIBS} ws2_32)
	ELSE (WIN32)
		FIND_PACKAGE(Threads)
		SET(MYSQL_CLIENT_LIBS ${MYSQL_CLIENT_LIBS} ${CMAKE_THREAD_LIBS_INIT})
	ENDIF (WIN32)

	MESSAGE(STATUS "MySQL Include dir: ${MYSQL_INCLUDE_DIR}  library dir: ${MYSQL_LIB_DIR}")
	MESSAGE(STATUS "MySQL client libraries: ${MYSQL_CLIENT_LIBS}")
ELSE (MYSQL_INCLUDE_DIR AND MYSQL_LIB_DIR)
	MESSAGE(FATAL_ERROR "Cannot find MySQL. Include dir: ${MYSQL_INCLUDE_DIR}  library dir: ${MYSQL_LIB_DIR}")
ENDIF (MYSQL_INCLUDE_DIR AND MYSQL_LIB_DIR)

