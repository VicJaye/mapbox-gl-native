#include <mbgl/renderer/debug_bucket.hpp>
#include <mbgl/renderer/painter.hpp>
#include <mbgl/shader/plain_shader.hpp>
#include <mbgl/util/time.hpp>

#include <mbgl/platform/gl.hpp>

#include <cassert>
#include <string>

using namespace mbgl;

DebugBucket::DebugBucket(const TileID id, const TileData::State state_, time_t modified_, time_t expires_)
    : state(state_),
      modified(modified_),
      expires(expires_) {
    const std::string text = std::string(id) + " - " + TileData::StateToString(state);
    fontBuffer.addText(text.c_str(), 50, 200, 5);

    if (modified > 0 && expires > 0) {
        const std::string modifiedText = "modified: " + util::rfc1123(modified);
        fontBuffer.addText(modifiedText.c_str(), 50, 400, 5);

        const std::string expiresText = "expires: " + util::rfc1123(expires);
        fontBuffer.addText(expiresText.c_str(), 50, 600, 5);
    }
}

void DebugBucket::drawLines(PlainShader& shader) {
    array.bind(shader, fontBuffer, BUFFER_OFFSET_0);
    MBGL_CHECK_ERROR(glDrawArrays(GL_LINES, 0, (GLsizei)(fontBuffer.index())));
}

void DebugBucket::drawPoints(PlainShader& shader) {
    array.bind(shader, fontBuffer, BUFFER_OFFSET_0);
    MBGL_CHECK_ERROR(glDrawArrays(GL_POINTS, 0, (GLsizei)(fontBuffer.index())));
}
