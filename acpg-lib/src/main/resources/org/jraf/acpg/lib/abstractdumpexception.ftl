<#if header??>
${header}
</#if>
package ${config.providerJavaPackage}.base;
// @formatter:off
import android.os.Build;
import androidx.annotation.RequiresApi;
@SuppressWarnings("unused")
public class AbstractDumpException extends Exception {

    public AbstractDumpException(String message) {
        super(message);
    }

    public AbstractDumpException(String message, Throwable cause) {
        super(message, cause);
    }

    public AbstractDumpException(Throwable cause) {
        super(cause);
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    public AbstractDumpException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
        super(message, cause, enableSuppression, writableStackTrace);
    }

}