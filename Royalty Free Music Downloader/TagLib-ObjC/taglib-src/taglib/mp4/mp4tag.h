/**************************************************************************
    copyright            : (C) 2007 by Lukáš Lalinský
    email                : lalinsky@gmail.com
 **************************************************************************/

/***************************************************************************
 *   This library is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Lesser General Public License version   *
 *   2.1 as published by the Free Software Foundation.                     *
 *                                                                         *
 *   This library is distributed in the hope that it will be useful, but   *
 *   WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 *   Lesser General Public License for more details.                       *
 *                                                                         *
 *   You should have received a copy of the GNU Lesser General Public      *
 *   License along with this library; if not, write to the Free Software   *
 *   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA         *
 *   02110-1301  USA                                                       *
 *                                                                         *
 *   Alternatively, this file is available under the Mozilla Public        *
 *   License Version 1.1.  You may obtain a copy of the License at         *
 *   http://www.mozilla.org/MPL/                                           *
 ***************************************************************************/

#ifndef TAGLIB_MP4TAG_H
#define TAGLIB_MP4TAG_H

#include "tag.h"
#include "tbytevectorlist.h"
#include "tfile.h"
#include "tmap.h"
#include "tstringlist.h"
#include "taglib_export.h"
#include "mp4atom.h"
#include "mp4item.h"
#include "mp4coverart.h"

namespace TagLib {

  namespace MP4 {

    typedef TagLib::Map<String, Item> ItemListMap;

    class TAGLIB_EXPORT Tag: public TagLib::Tag
    {
    public:
        Tag();
        Tag(TagLib::File *file, Atoms *atoms);
        ~Tag();
        bool save();

        String title() const;
        String artist() const;
        String albumArtist() const;
        String album() const;
        String comment() const;
        String genre() const;
        String grouping() const;
        uint year() const;
        uint track() const;

        void setTitle(const String &value);
        void setArtist(const String &value);
        void setAlbumArtist(const String &value);
        void setAlbum(const String &value);
        void setComment(const String &value);
        void setGenre(const String &value);
        void setGrouping(const String &value);
        void setYear(uint value);
        void setTrack(uint value);

        ItemListMap &itemListMap();
        
        /*!
         * Returns a picture or null if not supported by the container or tag or
         * if none are present. A picture is chosen non-deterministically if several
         * are present, with a preference for album covers, then artist images and
         * thumbnails as the lowest preference, if applicable.
         */
        virtual CoverArt *picture() const;

        //typedef const class _PictureList : public List<CoverArt*>, public ReadonlyList<Picture*>
        //{
        //} &PictureList;
        typedef Tag::_PictureList _PictureList;
        typedef Tag::PictureList PictureList;
      
        /*!
         * Returns a list of all pictures found, which will be empty if not supported
         * by the container or tag or if none are present.
         */
        PictureList pictures() const;

    private:
        TagLib::ByteVectorList parseData(Atom *atom, TagLib::File *file, int expectedFlags = -1, bool freeForm = false);
        void parseText(Atom *atom, TagLib::File *file, int expectedFlags = 1);
        void parseFreeForm(Atom *atom, TagLib::File *file);
        void parseInt(Atom *atom, TagLib::File *file);
        void parseByte(Atom *atom, TagLib::File *file);
        void parseUInt(Atom *atom, TagLib::File *file);
        void parseLongLong(Atom *atom, TagLib::File *file);
        void parseGnre(Atom *atom, TagLib::File *file);
        void parseIntPair(Atom *atom, TagLib::File *file);
        void parseBool(Atom *atom, TagLib::File *file);
        void parseCovr(Atom *atom, TagLib::File *file);

        TagLib::ByteVector padIlst(const ByteVector &data, int length = -1);
        TagLib::ByteVector renderAtom(const ByteVector &name, const TagLib::ByteVector &data);
        TagLib::ByteVector renderData(const ByteVector &name, int flags, const TagLib::ByteVectorList &data);
        TagLib::ByteVector renderText(const ByteVector &name, Item &item, int flags = 1);
        TagLib::ByteVector renderFreeForm(const String &name, Item &item);
        TagLib::ByteVector renderBool(const ByteVector &name, Item &item);
        TagLib::ByteVector renderInt(const ByteVector &name, Item &item);
        TagLib::ByteVector renderByte(const ByteVector &name, Item &item);
        TagLib::ByteVector renderUInt(const ByteVector &name, Item &item);
        TagLib::ByteVector renderLongLong(const ByteVector &name, Item &item);
        TagLib::ByteVector renderIntPair(const ByteVector &name, Item &item);
        TagLib::ByteVector renderIntPairNoTrailing(const ByteVector &name, Item &item);
        TagLib::ByteVector renderCovr(const ByteVector &name, Item &item);

        void updateParents(AtomList &path, long delta, int ignore = 0);
        void updateOffsets(long delta, long offset);

        void saveNew(TagLib::ByteVector &data);
        void saveExisting(TagLib::ByteVector &data, AtomList &path);

        class TagPrivate;
        TagPrivate *d;
    };

  }

}

#endif