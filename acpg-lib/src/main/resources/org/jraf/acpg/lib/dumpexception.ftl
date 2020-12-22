<#if header??>
${header}
</#if>
package ${config.providerJavaPackage}.${entity.packageName};
// @formatter:off
import ${config.providerJavaPackage}.base.AbstractDumpException;
import android.os.Build;
import androidx.annotation.RequiresApi;
/**
<#if entity.documentation??>
 * ${entity.documentation}
<#else>
 * Columns for the {@code ${entity.nameLowerCase}} table.
</#if>
 */
@SuppressWarnings("unused")
public class ${entity.nameCamelCase}DumpException extends AbstractDumpException {


    public ${entity.nameCamelCase}DumpException(String message) {
        super(message);
    }

    public ${entity.nameCamelCase}DumpException(String message, Throwable cause) {
        super(message, cause);
    }

    public ${entity.nameCamelCase}DumpException(Throwable cause) {
        super(cause);
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    public ${entity.nameCamelCase}DumpException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
        super(message, cause, enableSuppression, writableStackTrace);
    }
}